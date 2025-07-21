<script lang="ts">
  import { signIn } from '../lib/auth'
  import { addNotification } from '../lib/stores'
  import { push } from 'svelte-spa-router'
  import { link } from 'svelte-spa-router'
  import Button from '../lib/components/Button.svelte'
  import Card from '../lib/components/Card.svelte'
  import { onMount } from 'svelte'
  import { fadeInUp } from '../lib/animations'

  let formElement: HTMLElement
  let email = ''
  let password = ''
  let isLoading = false

  async function handleSignIn() {
    isLoading = true
    try {
      await signIn(email, password)
      addNotification('success', 'Signed in successfully!')
      push('/dashboard')
    } catch (error) {
      addNotification('error', error.message || 'Failed to sign in')
    } finally {
      isLoading = false
    }
  }

  onMount(() => {
    if (formElement) {
      fadeInUp(formElement)
    }
  })
</script>

<div class="min-h-screen bg-gray-50 dark:bg-gray-900 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
  <div class="sm:mx-auto sm:w-full sm:max-w-md">
    <h2 class="mt-6 text-center text-3xl font-bold text-gray-900 dark:text-white">
      Welcome Back
    </h2>
    <p class="mt-2 text-center text-sm text-gray-600 dark:text-gray-400">
      Don't have an account?
      <a href="/signup" use:link class="font-medium text-primary-600 hover:text-primary-500 dark:text-primary-400 dark:hover:text-primary-300">
        Sign up for free
      </a>
    </p>
  </div>

  <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
    <Card bind:this={formElement} padding="lg">
      <form on:submit|preventDefault={handleSignIn} class="space-y-6">
        <div>
          <label for="email" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
            Email Address
          </label>
          <input
            id="email"
            bind:value={email}
            type="email"
            required
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:border-gray-600 dark:text-white"
          />
        </div>

        <div>
          <label for="password" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
            Password
          </label>
          <input
            id="password"
            bind:value={password}
            type="password"
            required
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:border-gray-600 dark:text-white"
          />
        </div>

        <div class="flex items-center justify-between">
          <div class="flex items-center">
            <input
              id="remember-me"
              type="checkbox"
              class="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
            />
            <label for="remember-me" class="ml-2 block text-sm text-gray-700 dark:text-gray-300">
              Remember me
            </label>
          </div>

          <div class="text-sm">
            <a href="/forgot-password" use:link class="font-medium text-primary-600 hover:text-primary-500 dark:text-primary-400 dark:hover:text-primary-300">
              Forgot password?
            </a>
          </div>
        </div>

        <Button type="submit" loading={isLoading} disabled={isLoading} size="lg" class="w-full">
          Sign In
        </Button>
      </form>
    </Card>
  </div>
</div>