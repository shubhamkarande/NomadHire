import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

// Validate environment variables
if (!supabaseUrl || supabaseUrl === 'your_supabase_url_here' || !supabaseUrl.startsWith('https://')) {
  console.error('Invalid or missing VITE_SUPABASE_URL. Please check your .env file.')
}

if (!supabaseAnonKey || supabaseAnonKey === 'your_supabase_anon_key_here') {
  console.error('Invalid or missing VITE_SUPABASE_ANON_KEY. Please check your .env file.')
}

// Use fallback values to prevent crashes during development
const validUrl = (supabaseUrl && supabaseUrl.startsWith('https://')) ? supabaseUrl : 'https://placeholder.supabase.co'
const validKey = (supabaseAnonKey && supabaseAnonKey !== 'your_supabase_anon_key_here') ? supabaseAnonKey : 'placeholder-key'

export const supabase = createClient(validUrl, validKey)

export type UserRole = 'freelancer' | 'client' | 'admin'

export interface Profile {
  id: string
  email: string
  role: UserRole
  first_name: string
  last_name: string
  avatar_url?: string
  bio?: string
  skills?: string[]
  hourly_rate?: number
  location?: string
  created_at: string
  updated_at: string
}

export interface Project {
  id: string
  title: string
  description: string
  budget: number
  budget_type: 'fixed' | 'hourly'
  skills_required: string[]
  deadline: string
  status: 'open' | 'in_progress' | 'completed' | 'cancelled'
  client_id: string
  freelancer_id?: string
  created_at: string
  updated_at: string
}

export interface Bid {
  id: string
  project_id: string
  freelancer_id: string
  amount: number
  proposal: string
  delivery_time: number
  status: 'pending' | 'accepted' | 'rejected'
  created_at: string
}

export interface Message {
  id: string
  project_id: string
  sender_id: string
  receiver_id: string
  content: string
  created_at: string
}

export interface Milestone {
  id: string
  project_id: string
  title: string
  description: string
  amount: number
  due_date: string
  status: 'pending' | 'in_progress' | 'completed' | 'approved'
  created_at: string
}