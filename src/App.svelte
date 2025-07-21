<script lang="ts">
  import './app.css'
  import router from 'svelte-spa-router'
  import { onMount } from 'svelte'
  import { theme } from './lib/stores'
  import { getCurrentUser } from './lib/auth'
  
  // Components
  import Navbar from './lib/components/Navbar.svelte'
  import Footer from './lib/components/Footer.svelte'
  import Notification from './lib/components/Notification.svelte'

  // Import route components
  import Landing from './routes/Landing.svelte'
  import Browse from './routes/Browse.svelte'

  // Routes
  const routes = {
    '/': Landing,
    '/browse': Browse,
    '*': Landing // Fallback route
  }

  onMount(async () => {
    // Initialize theme
    const savedTheme = localStorage.getItem('theme') || 'light'
    theme.set(savedTheme as 'light' | 'dark')
    document.documentElement.classList.toggle('dark', savedTheme === 'dark')

    // Subscribe to theme changes
    theme.subscribe(currentTheme => {
      localStorage.setItem('theme', currentTheme)
      document.documentElement.classList.toggle('dark', currentTheme === 'dark')
    })

    // Initialize user authentication
    try {
      await getCurrentUser()
    } catch (error) {
      console.warn('Auth initialization failed:', error)
    }
  })
</script>

<main class="min-h-screen bg-gray-50 dark:bg-gray-900 transition-colors duration-300">
  <Navbar />
  <div class="min-h-screen">
    <svelte:component this={router} {routes} />
  </div>
  <Footer />
  <Notification />
</main>

<style>
  :global(html) {
    scroll-behavior: smooth;
  }
  
  :global(.line-clamp-2) {
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }
  
  :global(.line-clamp-3) {
    display: -webkit-box;
    -webkit-line-clamp: 3;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }
</style>