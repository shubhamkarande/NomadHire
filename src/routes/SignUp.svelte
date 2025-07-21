<script lang="ts">
  import { signUp } from '../lib/auth'
  import { addNotification } from '../lib/stores'
  import { push } from 'svelte-spa-router'
  import { link } from 'svelte-spa-router'
  import Button from '../lib/components/Button.svelte'
  import Card from '../lib/components/Card.svelte'
  import { onMount } from 'svelte'
  import { fadeInUp } from '../lib/animations'
  import type { UserRole } from '../lib/supabase'

  let formElement: HTMLElement
  let email = ''
  let password = ''
  let confirmPassword = ''
  let firstName = ''
  let lastName = ''
  let role: UserRole = 'freelancer'
  let isLoading = false

  async function handleSignUp() {
    if (password !== confirmPassword) {
      addNotification('error', 'Passwords do not match')
      return
    }

    if (password.length < 6) {
      addNotification('error', 'Password must be at least 6 characters')
      return
    }

    isLoading = true
    try {
      await signUp(email, password, role, firstName, lastName)
      addNotification('success', 'Account created successfully!')
      push('/dashboard')
    } catch (error) {
      addNotification('error', error.message || 'Failed to create account')
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
      Join NomadHire
    </h2>
    <p class="mt-2 text-center text-sm text-gray-600 dark:text-gray-400">
      Already have an account?
      <a href="/login" use:link class="font-medium text-primary-600 hover:text-primary-500 dark:text-primary-400 dark:hover:text-primary-300">
        Sign in
      </a>
    </p>
  </div>

  <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
    <Card bind:this={formElement} padding="lg">
      <form on:submit|preventDefault={handleSignUp} class="space-y-6">
        <!-- Role Selection -->
        <div>
          <label class="text-base font-medium text-gray-900 dark:text-white">
            I want to:
          </label>
          <fieldset class="mt-4">
            <div class="space-y-4 sm:flex sm:items-center sm:space-y-0 sm:space-x-10">
              <div class="flex items-center">
                <input
                  id="freelancer"
                  bind:group={role}
                  value="freelancer"
                  type="radio"
                  class="focus:ring-primary-500 h-4 w-4 text-primary-600 border-gray-300"
                />
                <label for="freelancer" class="ml-3 block text-sm font-medium text-gray-700 dark:text-gray-300">
                  Work as a Freelancer
                </label>
              </div>
              <div class="flex items-center">
                <input
                  id="client"
                  bind:group={role}
                  value="client"
                  type="radio"
                  class="focus:ring-primary-500 h-4 w-4 text-primary-600 border-gray-300"
                />
                <label for="client" class="ml-3 block text-sm font-medium text-gray-700 dark:text-gray-300">
                  Hire Talent
                </label>
              </div>
            </div>
          </fieldset>
        </div>

        <!-- Name Fields -->
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label for="firstName" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
              First Name
            </label>
            <input
              id="firstName"
              bind:value={firstName}
              type="text"
              required
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:border-gray-600 dark:text-white"
            />
          </div>
          <div>
            <label for="lastName" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
              Last Name
            </label>
            <input
              id="lastName"
              bind:value={lastName}
              type="text"
              required
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:border-gray-600 dark:text-white"
            />
          </div>
        </div>

        <!-- Email -->
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

        <!-- Password -->
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

        <!-- Confirm Password -->
        <div>
          <label for="confirmPassword" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
            Confirm Password
          </label>
          <input
            id="confirmPassword"
            bind:value={confirmPassword}
            type="password"
            required
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:border-gray-600 dark:text-white"
          />
        </div>

        <Button type="submit" loading={isLoading} disabled={isLoading} size="lg" class="w-full">
          Create Account
        </Button>
      </form>
    </Card>
  </div>
</div>