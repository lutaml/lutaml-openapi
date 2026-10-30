// UI string catalog. `en` is the source of truth; additional locales add
// entries under their own key. Keys are flat and namespaced per component.
// A missing key in any locale is a type error against messages.en.
export const messages = {
  en: {
    'app.titleFallback': 'OpenAPI document',
    'app.version': 'version',
    'app.filterPlaceholder': 'Filter…',
    'app.filterAria': 'Filter sections',
    'app.switchLocale': 'Switch locale',

    'nav.overview': 'Overview',
    'nav.paths': 'Paths',
    'nav.schemas': 'Schemas',
    'nav.sections': 'Sections',

    'overview.heading': 'Overview',
    'overview.servers': 'Servers',

    'paths.heading': 'Paths',
    'paths.noMatch': 'No paths match the filter.',

    'schemas.heading': 'Schemas',
    'schemas.propertiesOf': 'Properties of {name}',
    'schemas.name': 'Name',
    'schemas.type': 'Type',
    'schemas.description': 'Description',
    'schemas.noMatch': 'No schemas match the filter.',

    'footer.stats': '{schemas} schemas · {paths} paths',
  },

  ar: {
    'app.titleFallback': 'وثيقة OpenAPI',
    'app.version': 'الإصدار',
    'app.filterPlaceholder': 'تصفية…',
    'app.filterAria': 'تصفية الأقسام',
    'app.switchLocale': 'تبديل اللغة',

    'nav.overview': 'نظرة عامة',
    'nav.paths': 'المسارات',
    'nav.schemas': 'الأنماط',
    'nav.sections': 'الأقسام',

    'overview.heading': 'نظرة عامة',
    'overview.servers': 'الخوادم',

    'paths.heading': 'المسارات',
    'paths.noMatch': 'لا توجد مسارات مطابقة للتصفية.',

    'schemas.heading': 'الأنماط',
    'schemas.propertiesOf': 'خصائص {name}',
    'schemas.name': 'الاسم',
    'schemas.type': 'النوع',
    'schemas.description': 'الوصف',
    'schemas.noMatch': 'لا توجد أنماط مطابقة للتصفية.',

    'footer.stats': '{schemas} أنماط · {paths} مسارات',
  },
} as const

export type Locale = keyof typeof messages
export type MessageKey = keyof typeof messages.en
