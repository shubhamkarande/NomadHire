// API Client for NomadHire backend
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3001/api/v1';

interface RequestOptions {
    method?: 'GET' | 'POST' | 'PATCH' | 'PUT' | 'DELETE';
    body?: unknown;
    headers?: Record<string, string>;
}

interface ApiResponse<T> {
    data?: T;
    error?: string;
    errors?: Record<string, string[]>;
}

class ApiClient {
    private token: string | null = null;

    constructor() {
        if (typeof window !== 'undefined') {
            this.token = localStorage.getItem('auth_token');
        }
    }

    setToken(token: string | null) {
        this.token = token;
        if (typeof window !== 'undefined') {
            if (token) {
                localStorage.setItem('auth_token', token);
            } else {
                localStorage.removeItem('auth_token');
            }
        }
    }

    getToken(): string | null {
        return this.token;
    }

    private async request<T>(endpoint: string, options: RequestOptions = {}): Promise<ApiResponse<T>> {
        const { method = 'GET', body, headers = {} } = options;

        const requestHeaders: Record<string, string> = {
            'Content-Type': 'application/json',
            ...headers
        };

        if (this.token) {
            requestHeaders['Authorization'] = `Bearer ${this.token}`;
        }

        try {
            const response = await fetch(`${API_URL}${endpoint}`, {
                method,
                headers: requestHeaders,
                body: body ? JSON.stringify(body) : undefined
            });

            const data = await response.json();

            if (!response.ok) {
                return {
                    error: data.error || 'An error occurred',
                    errors: data.errors
                };
            }

            return { data };
        } catch (error) {
            console.error('API request failed:', error);
            return { error: 'Network error. Please try again.' };
        }
    }

    // Auth endpoints
    async signUp(userData: { name: string; email: string; password: string; password_confirmation: string; role: string }) {
        return this.request<{ user: User; token: string }>('/auth/sign_up', {
            method: 'POST',
            body: { user: userData }
        });
    }

    async signIn(credentials: { email: string; password: string }) {
        return this.request<{ user: User; token: string }>('/auth/sign_in', {
            method: 'POST',
            body: { user: credentials }
        });
    }

    async signOut() {
        const result = await this.request('/auth/sign_out', { method: 'DELETE' });
        this.setToken(null);
        return result;
    }

    async getMe() {
        return this.request<{ user: User }>('/auth/me');
    }

    // Users
    async getUser(id: number) {
        return this.request<{ user: User }>(`/users/${id}`);
    }

    async updateUser(id: number, userData: Partial<User>) {
        return this.request<{ user: User }>(`/users/${id}`, {
            method: 'PATCH',
            body: { user: userData }
        });
    }

    async searchFreelancers(params: Record<string, string | string[]> = {}) {
        const query = new URLSearchParams();
        Object.entries(params).forEach(([key, value]) => {
            if (Array.isArray(value)) {
                value.forEach(v => query.append(key, v));
            } else if (value) {
                query.append(key, value);
            }
        });
        return this.request<{ freelancers: User[]; meta: PaginationMeta }>(`/search/freelancers?${query.toString()}`);
    }

    // Jobs
    async getJobs(params: Record<string, string | string[]> = {}) {
        const query = new URLSearchParams();
        Object.entries(params).forEach(([key, value]) => {
            if (Array.isArray(value)) {
                value.forEach(v => query.append(key, v));
            } else if (value) {
                query.append(key, value);
            }
        });
        return this.request<{ jobs: Job[]; meta: PaginationMeta }>(`/jobs?${query.toString()}`);
    }

    async getJob(id: number) {
        return this.request<{ job: Job }>(`/jobs/${id}`);
    }

    async createJob(jobData: Partial<Job>) {
        return this.request<{ job: Job }>('/jobs', {
            method: 'POST',
            body: { job: jobData }
        });
    }

    async updateJob(id: number, jobData: Partial<Job>) {
        return this.request<{ job: Job }>(`/jobs/${id}`, {
            method: 'PATCH',
            body: { job: jobData }
        });
    }

    async deleteJob(id: number) {
        return this.request(`/jobs/${id}`, { method: 'DELETE' });
    }

    // Bids
    async getJobBids(jobId: number) {
        return this.request<{ bids: Bid[] }>(`/jobs/${jobId}/bids`);
    }

    async createBid(jobId: number, bidData: { amount: number; cover_letter: string; estimated_days: number }) {
        return this.request<{ bid: Bid }>(`/jobs/${jobId}/bids`, {
            method: 'POST',
            body: { bid: bidData }
        });
    }

    async acceptBid(bidId: number) {
        return this.request<{ message: string; contract: Contract }>(`/bids/${bidId}/accept`, {
            method: 'POST'
        });
    }

    async declineBid(bidId: number) {
        return this.request(`/bids/${bidId}/decline`, { method: 'POST' });
    }

    async withdrawBid(bidId: number) {
        return this.request(`/bids/${bidId}/withdraw`, { method: 'POST' });
    }

    // Contracts
    async getContracts() {
        return this.request<{ contracts: Contract[] }>('/contracts');
    }

    async getContract(id: number) {
        return this.request<{ contract: Contract }>(`/contracts/${id}`);
    }

    // Milestones
    async createMilestone(contractId: number, milestoneData: Partial<Milestone>) {
        return this.request<{ milestone: Milestone }>(`/contracts/${contractId}/milestones`, {
            method: 'POST',
            body: { milestone: milestoneData }
        });
    }

    async payMilestone(id: number, provider: 'stripe' | 'razorpay' = 'stripe') {
        return this.request<{ client_secret?: string; payment_intent_id?: string; order_id?: string }>(`/milestones/${id}/pay`, {
            method: 'POST',
            body: { provider }
        });
    }

    async completeMilestone(id: number) {
        return this.request(`/milestones/${id}/complete`, { method: 'POST' });
    }

    async releaseMilestone(id: number) {
        return this.request(`/milestones/${id}/release`, { method: 'POST' });
    }

    // Conversations
    async getConversations() {
        return this.request<{ conversations: Conversation[] }>('/conversations');
    }

    async createConversation(recipientId: number) {
        return this.request<{ conversation: Conversation }>('/conversations', {
            method: 'POST',
            body: { recipient_id: recipientId }
        });
    }

    async getConversationMessages(id: number) {
        return this.request<{ messages: Message[] }>(`/conversations/${id}/messages`);
    }

    async sendMessage(conversationId: number, body: string) {
        return this.request<{ message: Message }>(`/conversations/${conversationId}/messages`, {
            method: 'POST',
            body: { body }
        });
    }

    // Notifications
    async getNotifications() {
        return this.request<{ notifications: Notification[]; unread_count: number }>('/notifications');
    }

    async markNotificationRead(id: number) {
        return this.request(`/notifications/${id}/read`, { method: 'PATCH' });
    }

    async markAllNotificationsRead() {
        return this.request('/notifications/read_all', { method: 'POST' });
    }

    // Reviews
    async getUserReviews(userId: number) {
        return this.request<{ reviews: Review[]; average_rating: number }>(`/users/${userId}/reviews`);
    }

    async createReview(contractId: number, reviewData: { rating: number; comment: string }) {
        return this.request<{ review: Review }>(`/contracts/${contractId}/reviews`, {
            method: 'POST',
            body: { review: reviewData }
        });
    }
}

// Types
export interface User {
    id: number;
    name: string;
    email: string;
    role: 'freelancer' | 'client' | 'admin';
    bio?: string;
    skills?: string[];
    hourly_rate?: number;
    location?: string;
    avatar_url?: string;
    rating_cache?: number;
    created_at?: string;
}

export interface Job {
    id: number;
    title: string;
    description: string;
    budget_min: number;
    budget_max?: number;
    budget_type: 'fixed' | 'hourly';
    skills: string[];
    deadline: string;
    status: string;
    client: {
        id: number;
        name: string;
        avatar_url?: string;
    };
    bids_count: number;
    bids?: Bid[];
    created_at: string;
}

export interface Bid {
    id: number;
    amount: number;
    cover_letter: string;
    estimated_days: number;
    status: string;
    freelancer: {
        id: number;
        name: string;
        avatar_url?: string;
        rating_cache?: number;
    };
    job_id: number;
    created_at: string;
}

export interface Contract {
    id: number;
    job: { id: number; title: string };
    client: { id: number; name: string; avatar_url?: string };
    freelancer: { id: number; name: string; avatar_url?: string };
    total_amount: number;
    status: string;
    total_paid: number;
    total_released: number;
    milestones?: Milestone[];
    created_at: string;
}

export interface Milestone {
    id: number;
    title: string;
    description?: string;
    amount: number;
    due_date: string;
    status: string;
    overdue: boolean;
    created_at: string;
}

export interface Conversation {
    id: number;
    other_participant: {
        id: number;
        name: string;
        avatar_url?: string;
    };
    unread_count: number;
    last_message?: {
        body: string;
        sender_id: number;
        created_at: string;
    };
    updated_at: string;
}

export interface Message {
    id: number;
    body: string;
    sender_id: number;
    sender_name: string;
    read_at?: string;
    created_at: string;
}

export interface Notification {
    id: number;
    kind: string;
    payload: Record<string, unknown>;
    read: boolean;
    created_at: string;
}

export interface Review {
    id: number;
    rating: number;
    comment: string;
    reviewer: {
        id: number;
        name: string;
        avatar_url?: string;
    };
    contract_id: number;
    created_at: string;
}

export interface PaginationMeta {
    current_page: number;
    per_page: number;
    total_pages: number;
    total_count: number;
}

// Export singleton instance
export const api = new ApiClient();
export default api;
