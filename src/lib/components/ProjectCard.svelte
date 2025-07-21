<script lang="ts">
  import { link } from 'svelte-spa-router'
  import { formatCurrency, formatRelativeTime, truncateText } from '../utils'
  import { Clock, DollarSign, User, MapPin } from 'lucide-svelte'
  import { onMount } from 'svelte'
  import { scaleOnHover } from '../animations'
  import type { Project } from '../supabase'

  export let project: Project & { client?: { first_name: string; last_name: string; location?: string } }

  let cardElement: HTMLElement

  onMount(() => {
    if (cardElement) {
      scaleOnHover(cardElement)
    }
  })
</script>

<div bind:this={cardElement} class="bg-white dark:bg-gray-800 rounded-lg shadow-md hover:shadow-xl border border-gray-200 dark:border-gray-700 p-6 transition-all duration-300">
  <div class="flex justify-between items-start mb-4">
    <h3 class="text-lg font-semibold text-gray-900 dark:text-white hover:text-primary-600 dark:hover:text-primary-400 transition-colors">
      <a href="/project/{project.id}" use:link class="line-clamp-2">
        {project.title}
      </a>
    </h3>
    <span class="px-2 py-1 text-xs font-medium bg-success-100 text-success-800 dark:bg-success-900 dark:text-success-200 rounded-full flex-shrink-0 ml-2">
      {project.status}
    </span>
  </div>

  <p class="text-gray-600 dark:text-gray-400 text-sm mb-4 line-clamp-3">
    {truncateText(project.description, 150)}
  </p>

  <div class="flex flex-wrap gap-2 mb-4">
    {#each project.skills_required.slice(0, 3) as skill}
      <span class="px-2 py-1 text-xs font-medium bg-primary-100 text-primary-800 dark:bg-primary-900 dark:text-primary-200 rounded">
        {skill}
      </span>
    {/each}
    {#if project.skills_required.length > 3}
      <span class="px-2 py-1 text-xs font-medium bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-400 rounded">
        +{project.skills_required.length - 3} more
      </span>
    {/if}
  </div>

  <div class="flex items-center justify-between text-sm text-gray-500 dark:text-gray-400 mb-4">
    <div class="flex items-center space-x-4">
      <div class="flex items-center">
        <DollarSign size={16} class="mr-1" />
        <span class="font-medium text-gray-900 dark:text-white">
          {formatCurrency(project.budget)}
        </span>
        <span class="ml-1">
          {project.budget_type}
        </span>
      </div>
      <div class="flex items-center">
        <Clock size={16} class="mr-1" />
        <span>{formatRelativeTime(project.created_at)}</span>
      </div>
    </div>
  </div>

  {#if project.client}
    <div class="flex items-center justify-between border-t border-gray-200 dark:border-gray-700 pt-4">
      <div class="flex items-center">
        <div class="w-8 h-8 bg-primary-100 dark:bg-primary-900 rounded-full flex items-center justify-center mr-3">
          <User size={16} class="text-primary-600 dark:text-primary-400" />
        </div>
        <div>
          <p class="text-sm font-medium text-gray-900 dark:text-white">
            {project.client.first_name} {project.client.last_name}
          </p>
          {#if project.client.location}
            <div class="flex items-center text-xs text-gray-500 dark:text-gray-400">
              <MapPin size={12} class="mr-1" />
              {project.client.location}
            </div>
          {/if}
        </div>
      </div>
      <a
        href="/project/{project.id}"
        use:link
        class="bg-primary-600 hover:bg-primary-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors"
      >
        View Details
      </a>
    </div>
  {/if}
</div>