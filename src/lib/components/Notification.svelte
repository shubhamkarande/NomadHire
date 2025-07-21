<script lang="ts">
  import { notifications } from '../stores'
  import { CheckCircle, XCircle, AlertTriangle, Info, X } from 'lucide-svelte'
  import { fade, fly } from 'svelte/transition'

  function dismissNotification(id: string) {
    notifications.update(current => current.filter(n => n.id !== id))
  }

  const icons = {
    success: CheckCircle,
    error: XCircle,
    warning: AlertTriangle,
    info: Info
  }

  const colorClasses = {
    success: 'bg-success-50 border-success-200 text-success-800',
    error: 'bg-error-50 border-error-200 text-error-800',
    warning: 'bg-warning-50 border-warning-200 text-warning-800',
    info: 'bg-primary-50 border-primary-200 text-primary-800'
  }
</script>

<div class="fixed top-4 right-4 z-50 space-y-2">
  {#each $notifications as notification (notification.id)}
    <div
      transition:fly={{ x: 300, duration: 300 }}
      class="flex items-center p-4 border rounded-lg shadow-lg max-w-sm {colorClasses[notification.type]}"
    >
      <svelte:component this={icons[notification.type]} size={20} class="mr-3 flex-shrink-0" />
      <p class="text-sm font-medium flex-1">{notification.message}</p>
      <button
        on:click={() => dismissNotification(notification.id)}
        class="ml-3 flex-shrink-0 hover:opacity-70 transition-opacity"
      >
        <X size={16} />
      </button>
    </div>
  {/each}
</div>