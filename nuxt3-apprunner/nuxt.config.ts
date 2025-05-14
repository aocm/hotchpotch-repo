// https://nuxt.com/docs/api/configuration/nuxt-config
import BasicAuth from 'nuxt-basic-authentication-module'
export default defineNuxtConfig({
  compatibilityDate: '2024-11-01',
  devtools: { enabled: true },
  modules: [
    [BasicAuth, { enabled: true }],
    '@nuxt/ui'
  ],
  runtimeConfig: {
    basicAuth: {
      pairs: {
        'admin': 'password', // 任意の値に変更もしくは環境変数へ
      },
    },
  },
})