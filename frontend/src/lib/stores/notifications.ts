import { writable, derived } from 'svelte/store';
import { api, type Notification } from '$lib/api';

interface NotificationsState {
    notifications: Notification[];
    unreadCount: number;
    isLoading: boolean;
}

function createNotificationsStore() {
    const { subscribe, set, update } = writable<NotificationsState>({
        notifications: [],
        unreadCount: 0,
        isLoading: false
    });

    return {
        subscribe,

        async load() {
            update(state => ({ ...state, isLoading: true }));
            const result = await api.getNotifications();
            if (result.data) {
                set({
                    notifications: result.data.notifications,
                    unreadCount: result.data.unread_count,
                    isLoading: false
                });
            } else {
                update(state => ({ ...state, isLoading: false }));
            }
        },

        addNotification(notification: Notification) {
            update(state => ({
                notifications: [notification, ...state.notifications],
                unreadCount: state.unreadCount + 1,
                isLoading: false
            }));
        },

        async markAsRead(id: number) {
            await api.markNotificationRead(id);
            update(state => ({
                ...state,
                notifications: state.notifications.map(n =>
                    n.id === id ? { ...n, read: true } : n
                ),
                unreadCount: Math.max(0, state.unreadCount - 1)
            }));
        },

        async markAllAsRead() {
            await api.markAllNotificationsRead();
            update(state => ({
                ...state,
                notifications: state.notifications.map(n => ({ ...n, read: true })),
                unreadCount: 0
            }));
        },

        clear() {
            set({ notifications: [], unreadCount: 0, isLoading: false });
        }
    };
}

export const notifications = createNotificationsStore();
export const unreadCount = derived(notifications, $n => $n.unreadCount);
