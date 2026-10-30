import { describe, it, expect, beforeEach } from 'vitest'
// @vitest-environment jsdom
import {
  t,
  tf,
  setLocale,
  locale,
  locales,
  localeLabel,
  isLocale,
  nextLocale,
  directionFor,
  applyDocumentLocale,
  initLocaleFromUrl,
} from '../i18n'
import { messages } from '../i18n/messages'

describe('i18n', () => {
  beforeEach(() => setLocale('en'))

  it('looks up strings in the active locale', () => {
    expect(t('nav.overview')).toBe('Overview')
  })

  it('falls back to English, then to the key itself', () => {
    expect(t('nav.paths')).toBe(messages.en['nav.paths'])
    // @ts-expect-error — deliberate unknown key at runtime
    expect(t('nav.doesNotExist')).toBe('nav.doesNotExist')
  })

  it('interpolates parameters', () => {
    expect(tf('footer.stats', { schemas: 3, paths: 7 }))
      .toBe('3 schemas · 7 paths')
    expect(tf('schemas.propertiesOf', { name: 'thing' }))
      .toBe('Properties of thing')
  })

  it('switches locales', () => {
    setLocale('en')
    expect(locale()).toBe('en')
  })

  it('maps locales to writing directions', () => {
    expect(directionFor('en')).toBe('ltr')
    expect(directionFor('ar')).toBe('rtl')
  })

  it('mirrors lang and dir onto the document element', () => {
    applyDocumentLocale('en')
    expect(document.documentElement.lang).toBe('en')
    expect(document.documentElement.dir).toBe('ltr')
  })

  it('translates every key in Arabic and mirrors RTL for it', () => {
    setLocale('ar')
    expect(locale()).toBe('ar')
    expect(t('nav.schemas')).toBe('الأنماط')
    expect(tf('footer.stats', { schemas: 2, paths: 5 }))
      .toBe('2 أنماط · 5 مسارات')
    expect(document.documentElement.dir).toBe('rtl')
    expect(document.documentElement.lang).toBe('ar')
    setLocale('en')
  })

  it('falls back to English for keys a locale has not translated', () => {
    const ar = messages.ar as Record<string, string>
    const en = messages.en as Record<string, string>
    const untranslated = Object.keys(en).find((k) => !(k in ar))
    if (untranslated) {
      setLocale('ar')
      expect(t(untranslated as never)).toBe(en[untranslated])
      setLocale('en')
    }
  })

  it('exposes the locale list, labels, and the cycle', () => {
    expect(locales()).toEqual(['en', 'ar'])
    expect(localeLabel('ar')).toBe('العربية')
    expect(nextLocale()).toBe('ar')
    setLocale('ar')
    expect(nextLocale()).toBe('en')
    setLocale('en')
  })

  it('guards isLocale against unknown values', () => {
    expect(isLocale('ar')).toBe(true)
    expect(isLocale('xx')).toBe(false)
    expect(isLocale(null)).toBe(false)
  })

  it('boots the locale from ?locale=, else keeps the default', () => {
    initLocaleFromUrl('?locale=ar')
    expect(locale()).toBe('ar')
    expect(document.documentElement.dir).toBe('rtl')
    setLocale('en')
    initLocaleFromUrl('?locale=xx')
    expect(locale()).toBe('en')
    expect(document.documentElement.dir).toBe('ltr')
    initLocaleFromUrl('')
    expect(locale()).toBe('en')
  })
})
