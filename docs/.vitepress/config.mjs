import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "FileSystem",
  description: "A simple and powerful library to work with the file system in Swift.",
  sitemap: {
    hostname: 'https://file-system.tuist.io'
  },
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' }
    ],

    sidebar: [
      {
        text: 'FileSystem',
        items: [
          { text: 'What is FileSystem?', link: '/guides/what-is-file-system' },
          { text: 'Usage', link: '/guides/usage' },
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/tuist/FileSystem' },
      { icon: 'x', link: 'https://x.com/tuistio' },
      { icon: 'mastodon', link: 'https://fosstodon.org/@tuist' },
      { icon: 'slack', link: 'https://fosstodon.org/@tuist' },
      { icon: 'discord', link: 'https://discord.gg/MnqrEMRFDj' }
    ]
  }
})
