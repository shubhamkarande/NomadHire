import { writable } from 'svelte/store'
import type { Profile } from './supabase'

export const user = writable<Profile | null>(null)
export const theme = writable<'light' | 'dark'>('light')
export const isLoading = writable(false)
export const notifications = writable<Array<{
  id: string
  type: 'success' | 'error' | 'warning' | 'info'
  message: string
  timestamp: number
}>>([])

export function addNotification(type: 'success' | 'error' | 'warning' | 'info', message: string) {
  const id = Math.random().toString(36).substr(2, 9)
  notifications.update(current => [...current, {
    id,
    type,
    message,
    timestamp: Date.now()
  }])
  
  // Auto remove after 5 seconds
  setTimeout(() => {
    notifications.update(current => current.filter(n => n.id !== id))
  }, 5000)
}