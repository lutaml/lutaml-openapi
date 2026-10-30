# frozen_string_literal: true

module Lutaml
  module Openapi
    # The OpenAPI 3.0 frontend: normalizes 3.0 schema nodes into the
    # 3.1 shape as a pure hash walk. Applied only where the typed layer
    # consumes nodes — the document hash itself is stored verbatim, so
    # no denormalization exists.
    module Oas30
      module_function

      def normalize(hash)
        walk(hash) do |node|
          node = normalize_nullable(node)
          normalize_exclusive(node, "exclusiveMinimum", "minimum") ||
            normalize_exclusive(node, "exclusiveMaximum", "maximum") || node
        end
      end

      def walk(node, &)
        case node
        when Hash
          node = yield node
          node.transform_values { |v| walk(v, &) }
        when Array
          node.map { |v| walk(v, &) }
        else
          node
        end
      end

      # 3.0 `nullable: true` → a null-member type union; `nullable:
      # false` is dropped (3.1 default).
      def normalize_nullable(node)
        return node unless node.key?("nullable")

        nullable = node.delete("nullable")
        return node unless nullable == true

        types = Array(node["type"]).compact
        node["type"] = (types << "null").uniq unless types.include?("null")
        node
      end

      # 3.0 boolean exclusivity rides beside the bound; 3.1 carries the
      # bound in the exclusive* keyword itself.
      def normalize_exclusive(node, exclusive, bound)
        return node unless [true, false].include?(node[exclusive])

        flag = node.delete(exclusive)
        # the bound MOVES into exclusive*: minimum must not survive it
        node[exclusive] = node.delete(bound) if flag == true && node.key?(bound)
        node
      end
    end
  end
end
