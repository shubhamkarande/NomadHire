<script lang="ts">
  import { user, theme } from '../stores'
  import { signOut } from '../auth'
  import { link } from 'svelte-spa-router'
  import { Sun, Moon, Menu, X, User, LogOut, Settings } from 'lucide-svelte'
  import { onMount } from 'svelte'
  import { fadeInUp } from '../animations'

  let isMenuOpen = false
  let navbarElement: HTMLElement
  let isDropdownOpen = false

  function toggleTheme() {
    theme.update(current => {
      const newTheme = current === 'light' ? 'dark' : 'light'
      document.documentElement.classList.toggle('dark', newTheme === 'dark')
      return newTheme
    })
  }

  function toggleMenu() {
    isMenuOpen = !isMenuOpen
  }

  function toggleDropdown() {
    isDropdownOpen = !isDropdownOpen
  }

  async function handleSignOut() {
    await signOut()
    isDropdownOpen = false
  }

  onMount(() => {
    if (navbarElement) {
      fadeInUp(navbarElement)
    }
  })
</script>

<nav bind:this={navbarElement} class="bg-white dark:bg-gray-900 shadow-lg sticky top-0 z-50 transition-colors duration-300">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex justify-between items-center h-16">
      <!-- Logo -->
      <div class="flex-shrink-0">
        <a href="/" use:link class="text-2xl font-bold text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300 transition-colors">
          NomadHire
        </a>
      </div>

      <!-- Desktop Navigation -->
      <div class="hidden md:block">
        <div class="ml-10 flex items-baseline space-x-4">
          <a href="/browse" use:link class="text-gray-700 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 px-3 py-2 rounded-md text-sm font-medium transition-colors">
            Browse Projects
          </a>
          {#if $user}
            <a href="/dashboard" use:link class="text-gray-700 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 px-3 py-2 rounded-md text-sm font-medium transition-colors">
              Dashboard
            </a>
            {#if $user.role === 'client'}
              <a href="/post-job" use:link class="bg-primary-600 hover:bg-primary-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors">
                Post a Job
              </a>
            {/if}
          {:else}
            <a href="/login" use:link class="text-gray-700 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 px-3 py-2 rounded-md text-sm font-medium transition-colors">
              Log In
            </a>
            <a href="/signup" use:link class="bg-primary-600 hover:bg-primary-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors">
              Sign Up
            </a>
          {/if}
        </div>
      </div>

      <!-- Right side items -->
      <div class="hidden md:flex items-center space-x-4">
        <!-- Theme toggle -->
        <button
          on:click={toggleTheme}
          class="p-2 rounded-md text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-200 transition-colors"
          aria-label="Toggle theme"
        >
          {#if $theme === 'light'}
            <Moon size={20} />
          {:else}
            <Sun size={20} />
          {/if}
        </button>

        <!-- User dropdown -->
        {#if $user}
          <div class="relative">
            <button
              on:click={toggleDropdown}
              class="flex items-center space-x-2 p-2 rounded-md text-gray-700 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 transition-colors"
            >
              <div class="w-8 h-8 bg-primary-100 dark:bg-primary-900 rounded-full flex items-center justify-center">
                <User size={16} class="text-primary-600 dark:text-primary-400" />
              </div>
              <span class="text-sm font-medium">{$user.first_name}</span>
            </button>

            {#if isDropdownOpen}
              <div class="absolute right-0 mt-2 w-48 bg-white dark:bg-gray-800 rounded-md shadow-lg py-1 z-50 border dark:border-gray-700">
                <a href="/profile" use:link class="flex items-center px-4 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors">
                  <User size={16} class="mr-2" />
                  Profile
                </a>
                <a href="/settings" use:link class="flex items-center px-4 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors">
                  <Settings size={16} class="mr-2" />
                  Settings
                </a>
                <button
                  on:click={handleSignOut}
                  class="flex items-center w-full px-4 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                >
                  <LogOut size={16} class="mr-2" />
                  Sign Out
                </button>
              </div>
            {/if}
          </div>
        {/if}
      </div>

      <!-- Mobile menu button -->
      <div class="md:hidden flex items-center space-x-2">
        <button
          on:click={toggleTheme}
          class="p-2 rounded-md text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-200 transition-colors"
          aria-label="Toggle theme"
        >
          {#if $theme === 'light'}
            <Moon size={20} />
          {:else}
            <Sun size={20} />
          {/if}
        </button>
        
        <button
          on:click={toggleMenu}
          class="p-2 rounded-md text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-200 transition-colors"
          aria-label="Toggle menu"
        >
          {#if isMenuOpen}
            <X size={24} />
          {:else}
            <Menu size={24} />
          {/if}
        </button>
      </div>
    </div>

    <!-- Mobile Navigation -->
    {#if isMenuOpen}
      <div class="md:hidden">
        <div class="px-2 pt-2 pb-3 space-y-1 sm:px-3 bg-white dark:bg-gray-900 border-t dark:border-gray-700">
          <a href="/browse" use:link class="text-gray-700 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 block px-3 py-2 rounded-md text-base font-medium transition-colors">
            Browse Projects
          </a>
          {#if $user}
            <a href="/dashboard" use:link class="text-gray-700 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 block px-3 py-2 rounded-md text-base font-medium transition-colors">
              Dashboard
            </a>
            {#if $user.role === 'client'}
              <a href="/post-job" use:link class="text-gray-700 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 block px-3 py-2 rounded-md text-base font-medium transition-colors">
                Post a Job
              </a>
            {/if}
            <a href="/profile" use:link class="text-gray-700 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 block px-3 py-2 rounded-md text-base font-medium transition-colors">
              Profile
            </a>
            <button
              on:click={handleSignOut}
              class="text-gray-700 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 block w-full text-left px-3 py-2 rounded-md text-base font-medium transition-colors"
            >
              Sign Out
            </button>
          {:else}
            <a href="/login" use:link class="text-gray-700 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 block px-3 py-2 rounded-md text-base font-medium transition-colors">
              Log In
            </a>
            <a href="/signup" use:link class="bg-primary-600 hover:bg-primary-700 text-white block px-3 py-2 rounded-md text-base font-medium transition-colors">
              Sign Up
            </a>
          {/if}
        </div>
      </div>
    {/if}
  </div>
</nav>