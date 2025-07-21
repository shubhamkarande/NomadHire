<script lang="ts">
  import { onMount } from 'svelte'
  import { user } from '../lib/stores'
  import { push } from 'svelte-spa-router'
  import { link } from 'svelte-spa-router'
  import { BarChart3, Users, DollarSign, Clock, Plus, Eye, MessageSquare, Star } from 'lucide-svelte'
  import Button from '../lib/components/Button.svelte'
  import Card from '../lib/components/Card.svelte'
  import { fadeInUp, staggerFadeIn } from '../lib/animations'
  import { formatCurrency, formatRelativeTime } from '../lib/utils'

  let dashboardElement: HTMLElement

  // Mock data - replace with real data from Supabase
  const freelancerStats = {
    totalEarnings: 12500,
    activeProjects: 3,
    completedProjects: 28,
    averageRating: 4.8
  }

  const clientStats = {
    totalSpent: 45000,
    activeProjects: 5,
    completedProjects: 22,
    totalHires: 35
  }

  const recentProjects = [
    {
      id: '1',
      title: 'E-commerce Website Development',
      status: 'in_progress',
      budget: 2500,
      client: 'John Smith',
      deadline: '2025-02-15',
      progress: 75
    },
    {
      id: '2', 
      title: 'Mobile App UI Design',
      status: 'completed',
      budget: 1800,
      client: 'Sarah Johnson',
      deadline: '2025-01-20',
      progress: 100
    },
    {
      id: '3',
      title: 'WordPress Blog Setup',
      status: 'pending',
      budget: 800,
      client: 'Mike Davis',
      deadline: '2025-02-28',
      progress: 0
    }
  ]

  const recentMessages = [
    {
      id: '1',
      sender: 'John Smith',
      message: 'Great progress on the website! Looking forward to the next milestone.',
      time: '2025-01-10T10:30:00Z',
      unread: true
    },
    {
      id: '2',
      sender: 'Sarah Johnson',
      message: 'The design looks perfect. Ready to proceed with development.',
      time: '2025-01-09T15:45:00Z',
      unread: false
    }
  ]

  onMount(() => {
    if (!$user) {
      push('/login')
      return
    }

    if (dashboardElement) {
      fadeInUp(dashboardElement)
      
      setTimeout(() => {
        const cards = dashboardElement.querySelectorAll('[data-card]')
        staggerFadeIn(cards as NodeListOf<HTMLElement>, 0.1)
      }, 200)
    }
  })

  $: stats = $user?.role === 'freelancer' ? freelancerStats : clientStats
  $: dashboardTitle = $user?.role === 'freelancer' ? 'Freelancer Dashboard' : 'Client Dashboard'
</script>

{#if $user}
  <div bind:this={dashboardElement} class="min-h-screen bg-gray-50 dark:bg-gray-900">
    <!-- Header -->
    <div class="bg-white dark:bg-gray-800 shadow-sm border-b border-gray-200 dark:border-gray-700">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="flex justify-between items-center">
          <div>
            <h1 class="text-3xl font-bold text-gray-900 dark:text-white">
              Welcome back, {$user.first_name}!
            </h1>
            <p class="text-gray-600 dark:text-gray-400 mt-1">
              {dashboardTitle}
            </p>
          </div>
          
          {#if $user.role === 'client'}
            <Button href="/post-job">
              <Plus size={20} class="mr-2" />
              Post New Job
            </Button>
          {:else}
            <Button href="/browse">
              <Eye size={20} class="mr-2" />
              Browse Projects
            </Button>
          {/if}
        </div>
      </div>
    </div>

    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Stats Cards -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {#if $user.role === 'freelancer'}
          <Card data-card hover padding="md">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-success-100 dark:bg-success-900 rounded-md flex items-center justify-center">
                  <DollarSign size={20} class="text-success-600 dark:text-success-400" />
                </div>
              </div>
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Total Earnings</p>
                <p class="text-2xl font-semibold text-gray-900 dark:text-white">
                  {formatCurrency(stats.totalEarnings)}
                </p>
              </div>
            </div>
          </Card>

          <Card data-card hover padding="md">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-primary-100 dark:bg-primary-900 rounded-md flex items-center justify-center">
                  <BarChart3 size={20} class="text-primary-600 dark:text-primary-400" />
                </div>
              </div>
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Active Projects</p>
                <p class="text-2xl font-semibold text-gray-900 dark:text-white">
                  {stats.activeProjects}
                </p>
              </div>
            </div>
          </Card>

          <Card data-card hover padding="md">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-secondary-100 dark:bg-secondary-900 rounded-md flex items-center justify-center">
                  <Clock size={20} class="text-secondary-600 dark:text-secondary-400" />
                </div>
              </div>
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Completed</p>
                <p class="text-2xl font-semibold text-gray-900 dark:text-white">
                  {stats.completedProjects}
                </p>
              </div>
            </div>
          </Card>

          <Card data-card hover padding="md">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-warning-100 dark:bg-warning-900 rounded-md flex items-center justify-center">
                  <Star size={20} class="text-warning-600 dark:text-warning-400" />
                </div>
              </div>
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Rating</p>
                <p class="text-2xl font-semibold text-gray-900 dark:text-white">
                  {stats.averageRating}/5
                </p>
              </div>
            </div>
          </Card>
        {:else}
          <Card data-card hover padding="md">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-primary-100 dark:bg-primary-900 rounded-md flex items-center justify-center">
                  <DollarSign size={20} class="text-primary-600 dark:text-primary-400" />
                </div>
              </div>
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Total Spent</p>
                <p class="text-2xl font-semibold text-gray-900 dark:text-white">
                  {formatCurrency(stats.totalSpent)}
                </p>
              </div>
            </div>
          </Card>

          <Card data-card hover padding="md">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-secondary-100 dark:bg-secondary-900 rounded-md flex items-center justify-center">
                  <BarChart3 size={20} class="text-secondary-600 dark:text-secondary-400" />
                </div>
              </div>
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Active Projects</p>
                <p class="text-2xl font-semibold text-gray-900 dark:text-white">
                  {stats.activeProjects}
                </p>
              </div>
            </div>
          </Card>

          <Card data-card hover padding="md">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-success-100 dark:bg-success-900 rounded-md flex items-center justify-center">
                  <Clock size={20} class="text-success-600 dark:text-success-400" />
                </div>
              </div>
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Completed</p>
                <p class="text-2xl font-semibold text-gray-900 dark:text-white">
                  {stats.completedProjects}
                </p>
              </div>
            </div>
          </Card>

          <Card data-card hover padding="md">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-accent-100 dark:bg-accent-900 rounded-md flex items-center justify-center">
                  <Users size={20} class="text-accent-600 dark:text-accent-400" />
                </div>
              </div>
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Total Hires</p>
                <p class="text-2xl font-semibold text-gray-900 dark:text-white">
                  {stats.totalHires}
                </p>
              </div>
            </div>
          </Card>
        {/if}
      </div>

      <!-- Main Content Grid -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Recent Projects -->
        <div class="lg:col-span-2">
          <Card data-card padding="md">
            <div class="flex justify-between items-center mb-6">
              <h2 class="text-xl font-semibold text-gray-900 dark:text-white">
                Recent Projects
              </h2>
              <a href="/projects" use:link class="text-sm text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300">
                View all
              </a>
            </div>

            <div class="space-y-4">
              {#each recentProjects as project}
                <div class="border border-gray-200 dark:border-gray-700 rounded-lg p-4 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors">
                  <div class="flex justify-between items-start mb-2">
                    <h3 class="font-medium text-gray-900 dark:text-white">
                      <a href="/project/{project.id}" use:link class="hover:text-primary-600 dark:hover:text-primary-400">
                        {project.title}
                      </a>
                    </h3>
                    <span class="px-2 py-1 text-xs font-medium rounded-full {
                      project.status === 'completed' ? 'bg-success-100 text-success-800 dark:bg-success-900 dark:text-success-200' :
                      project.status === 'in_progress' ? 'bg-primary-100 text-primary-800 dark:bg-primary-900 dark:text-primary-200' :
                      'bg-warning-100 text-warning-800 dark:bg-warning-900 dark:text-warning-200'
                    }">
                      {project.status.replace('_', ' ')}
                    </span>
                  </div>
                  
                  <div class="flex justify-between items-center text-sm text-gray-500 dark:text-gray-400">
                    <span>{formatCurrency(project.budget)}</span>
                    <span>Due: {formatRelativeTime(project.deadline)}</span>
                  </div>

                  {#if project.status === 'in_progress'}
                    <div class="mt-3">
                      <div class="flex justify-between text-xs text-gray-500 dark:text-gray-400 mb-1">
                        <span>Progress</span>
                        <span>{project.progress}%</span>
                      </div>
                      <div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
                        <div class="bg-primary-600 h-2 rounded-full transition-all duration-300" style="width: {project.progress}%"></div>
                      </div>
                    </div>
                  {/if}
                </div>
              {/each}
            </div>
          </Card>
        </div>

        <!-- Recent Messages -->
        <div>
          <Card data-card padding="md">
            <div class="flex justify-between items-center mb-6">
              <h2 class="text-xl font-semibold text-gray-900 dark:text-white">
                Recent Messages
              </h2>
              <a href="/messages" use:link class="text-sm text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300">
                View all
              </a>
            </div>

            <div class="space-y-4">
              {#each recentMessages as message}
                <div class="flex items-start space-x-3 p-3 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors">
                  <div class="w-10 h-10 bg-primary-100 dark:bg-primary-900 rounded-full flex items-center justify-center flex-shrink-0">
                    <MessageSquare size={16} class="text-primary-600 dark:text-primary-400" />
                  </div>
                  <div class="flex-1 min-w-0">
                    <div class="flex justify-between items-center mb-1">
                      <p class="text-sm font-medium text-gray-900 dark:text-white">
                        {message.sender}
                      </p>
                      {#if message.unread}
                        <div class="w-2 h-2 bg-primary-600 rounded-full"></div>
                      {/if}
                    </div>
                    <p class="text-sm text-gray-600 dark:text-gray-400 truncate">
                      {message.message}
                    </p>
                    <p class="text-xs text-gray-500 dark:text-gray-500 mt-1">
                      {formatRelativeTime(message.time)}
                    </p>
                  </div>
                </div>
              {/each}
            </div>

            <div class="mt-6">
              <Button href="/messages" variant="outline" size="sm" class="w-full">
                View All Messages
              </Button>
            </div>
          </Card>
        </div>
      </div>
    </div>
  </div>
{/if}