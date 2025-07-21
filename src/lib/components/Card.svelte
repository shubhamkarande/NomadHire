<script lang="ts">
  export let padding: 'sm' | 'md' | 'lg' = 'md'
  export let shadow: 'sm' | 'md' | 'lg' | 'xl' = 'md'
  export let hover = false

  const paddingClasses = {
    sm: 'p-4',
    md: 'p-6',
    lg: 'p-8'
  }

  const shadowClasses = {
    sm: 'shadow-sm',
    md: 'shadow-md',
    lg: 'shadow-lg',
    xl: 'shadow-xl'
  }

  $: classes = `bg-white dark:bg-gray-800 rounded-lg ${paddingClasses[padding]} ${shadowClasses[shadow]} ${hover ? 'hover:shadow-xl hover:-translate-y-1 transition-all duration-300 cursor-pointer' : ''} border border-gray-200 dark:border-gray-700`
</script>

<div class={classes}>
  <slot />
</div>