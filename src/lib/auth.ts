import { supabase } from './supabase'
import { user } from './stores'
import type { UserRole } from './supabase'

export async function signUp(email: string, password: string, role: UserRole, firstName: string, lastName: string) {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        role,
        first_name: firstName,
        last_name: lastName
      }
    }
  })
  
  if (error) throw error
  return data
}

export async function signIn(email: string, password: string) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password
  })
  
  if (error) throw error
  return data
}

export async function signOut() {
  const { error } = await supabase.auth.signOut()
  if (error) throw error
  user.set(null)
}

export async function getCurrentUser() {
  const { data: { user: authUser } } = await supabase.auth.getUser()
  
  if (authUser) {
    const { data: profile } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', authUser.id)
      .single()
    
    if (profile) {
      user.set(profile)
      return profile
    }
  }
  
  return null
}

// Initialize auth state
supabase.auth.onAuthStateChange(async (event, session) => {
  if (session?.user) {
    await getCurrentUser()
  } else {
    user.set(null)
  }
})