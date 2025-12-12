import { writable, derived, get } from 'svelte/store';
import { api, type User } from '$lib/api';

interface AuthState {
    user: User | null;
    isLoading: boolean;
    isAuthenticated: boolean;
}

function createAuthStore() {
    const { subscribe, set, update } = writable<AuthState>({
        user: null,
        isLoading: true,
        isAuthenticated: false
    });

    return {
        subscribe,

        async init() {
            const token = api.getToken();
            if (!token) {
                set({ user: null, isLoading: false, isAuthenticated: false });
                return;
            }

            const result = await api.getMe();
            if (result.data?.user) {
                set({ user: result.data.user, isLoading: false, isAuthenticated: true });
            } else {
                api.setToken(null);
                set({ user: null, isLoading: false, isAuthenticated: false });
            }
        },

        async signUp(userData: { name: string; email: string; password: string; password_confirmation: string; role: string }) {
            const result = await api.signUp(userData);
            if (result.data) {
                api.setToken(result.data.token);
                set({ user: result.data.user, isLoading: false, isAuthenticated: true });
                return { success: true };
            }
            return { success: false, error: result.error, errors: result.errors };
        },

        async signIn(credentials: { email: string; password: string }) {
            const result = await api.signIn(credentials);
            if (result.data) {
                api.setToken(result.data.token);
                set({ user: result.data.user, isLoading: false, isAuthenticated: true });
                return { success: true };
            }
            return { success: false, error: result.error };
        },

        async signOut() {
            await api.signOut();
            set({ user: null, isLoading: false, isAuthenticated: false });
        },

        updateUser(user: User) {
            update(state => ({ ...state, user }));
        }
    };
}

export const auth = createAuthStore();

// Derived stores for convenience
export const user = derived(auth, $auth => $auth.user);
export const isAuthenticated = derived(auth, $auth => $auth.isAuthenticated);
export const isLoading = derived(auth, $auth => $auth.isLoading);
export const isClient = derived(auth, $auth => $auth.user?.role === 'client');
export const isFreelancer = derived(auth, $auth => $auth.user?.role === 'freelancer');
export const isAdmin = derived(auth, $auth => $auth.user?.role === 'admin');
