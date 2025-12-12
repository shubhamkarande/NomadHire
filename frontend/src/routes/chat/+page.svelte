<script lang="ts">
    import { onMount, onDestroy } from "svelte";
    import { goto } from "$app/navigation";
    import { api, type Conversation, type Message } from "$lib/api";
    import { user, isAuthenticated } from "$lib/stores/auth";
    import { ws } from "$lib/websocket";

    let conversations: Conversation[] = [];
    let selectedConversation: Conversation | null = null;
    let messages: Message[] = [];
    let newMessage = "";
    let isLoading = true;
    let isSending = false;
    let channelId: string | null = null;

    onMount(async () => {
        if (!$isAuthenticated) {
            goto("/auth/login");
            return;
        }

        await loadConversations();
        isLoading = false;
    });

    onDestroy(() => {
        if (channelId) {
            ws.unsubscribe(channelId);
        }
    });

    async function loadConversations() {
        const result = await api.getConversations();
        if (result.data) {
            conversations = result.data.conversations;
            if (conversations.length > 0 && !selectedConversation) {
                selectConversation(conversations[0]);
            }
        }
    }

    async function selectConversation(conversation: Conversation) {
        // Unsubscribe from previous channel
        if (channelId) {
            ws.unsubscribe(channelId);
        }

        selectedConversation = conversation;
        messages = [];

        // Load messages
        const result = await api.getConversationMessages(conversation.id);
        if (result.data) {
            messages = result.data.messages;
        }

        // Subscribe to channel for real-time updates
        channelId = ws.subscribe("ChatChannel", {
            conversation_id: conversation.id,
        });
        ws.on(channelId, "new_message", (data: any) => {
            messages = [...messages, data.message];
            scrollToBottom();
        });

        ws.on(channelId, "typing", (data: any) => {
            // Handle typing indicator
        });

        scrollToBottom();
    }

    async function sendMessage() {
        if (!newMessage.trim() || !selectedConversation) return;

        isSending = true;
        const result = await api.sendMessage(
            selectedConversation.id,
            newMessage,
        );

        if (result.data) {
            messages = [...messages, result.data.message];
            newMessage = "";
            scrollToBottom();
        }

        isSending = false;
    }

    function handleSubmit(e: Event) {
        e.preventDefault();
        sendMessage();
    }

    function scrollToBottom() {
        setTimeout(() => {
            const container = document.getElementById("messages-container");
            if (container) {
                container.scrollTop = container.scrollHeight;
            }
        }, 100);
    }

    function formatTime(dateString: string) {
        return new Date(dateString).toLocaleTimeString("en-US", {
            hour: "2-digit",
            minute: "2-digit",
        });
    }

    function formatDate(dateString: string) {
        const date = new Date(dateString);
        const today = new Date();

        if (date.toDateString() === today.toDateString()) {
            return "Today";
        }

        const yesterday = new Date(today);
        yesterday.setDate(yesterday.getDate() - 1);
        if (date.toDateString() === yesterday.toDateString()) {
            return "Yesterday";
        }

        return date.toLocaleDateString("en-US", {
            month: "short",
            day: "numeric",
        });
    }
</script>

<svelte:head>
    <title>Messages - NomadHire</title>
</svelte:head>

<div class="h-[calc(100vh-4rem)] flex">
    <!-- Conversations List -->
    <div class="w-80 border-r border-slate-200 bg-white flex flex-col">
        <div class="p-4 border-b border-slate-100">
            <h1 class="text-lg font-display font-bold text-slate-900">
                Messages
            </h1>
        </div>

        {#if isLoading}
            <div class="p-4 space-y-3">
                {#each [1, 2, 3] as _}
                    <div class="flex gap-3">
                        <div class="skeleton w-10 h-10 rounded-full"></div>
                        <div class="flex-1">
                            <div class="skeleton h-4 w-24 mb-2"></div>
                            <div class="skeleton h-3 w-full"></div>
                        </div>
                    </div>
                {/each}
            </div>
        {:else if conversations.length === 0}
            <div class="p-8 text-center text-slate-500">
                <div class="text-3xl mb-2">💬</div>
                <p class="text-sm">No conversations yet</p>
            </div>
        {:else}
            <div class="flex-1 overflow-y-auto">
                {#each conversations as conversation}
                    <button
                        on:click={() => selectConversation(conversation)}
                        class="w-full p-4 flex items-center gap-3 hover:bg-slate-50 transition-colors text-left {selectedConversation?.id ===
                        conversation.id
                            ? 'bg-primary-50 border-l-2 border-primary-600'
                            : ''}"
                    >
                        <div
                            class="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center flex-shrink-0"
                        >
                            <span class="text-primary-600 font-medium">
                                {conversation.other_participant.name.charAt(0)}
                            </span>
                        </div>
                        <div class="flex-1 min-w-0">
                            <div class="flex items-center justify-between mb-1">
                                <span
                                    class="font-medium text-slate-900 truncate"
                                >
                                    {conversation.other_participant.name}
                                </span>
                                {#if conversation.last_message}
                                    <span class="text-xs text-slate-400">
                                        {formatDate(
                                            conversation.last_message
                                                .created_at,
                                        )}
                                    </span>
                                {/if}
                            </div>
                            {#if conversation.last_message}
                                <p class="text-sm text-slate-500 truncate">
                                    {conversation.last_message.body}
                                </p>
                            {/if}
                        </div>
                        {#if conversation.unread_count > 0}
                            <span
                                class="w-5 h-5 bg-primary-600 text-white text-xs rounded-full flex items-center justify-center"
                            >
                                {conversation.unread_count}
                            </span>
                        {/if}
                    </button>
                {/each}
            </div>
        {/if}
    </div>

    <!-- Chat Area -->
    <div class="flex-1 flex flex-col bg-slate-50">
        {#if selectedConversation}
            <!-- Chat Header -->
            <div
                class="bg-white border-b border-slate-200 px-6 py-4 flex items-center gap-4"
            >
                <div
                    class="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center"
                >
                    <span class="text-primary-600 font-medium">
                        {selectedConversation.other_participant.name.charAt(0)}
                    </span>
                </div>
                <div>
                    <h2 class="font-medium text-slate-900">
                        {selectedConversation.other_participant.name}
                    </h2>
                    <p class="text-sm text-slate-500">Active now</p>
                </div>
            </div>

            <!-- Messages -->
            <div
                id="messages-container"
                class="flex-1 overflow-y-auto p-6 chat-scrollbar"
            >
                <div class="space-y-4 max-w-3xl mx-auto">
                    {#each messages as message}
                        <div
                            class="flex {message.sender_id === $user?.id
                                ? 'justify-end'
                                : 'justify-start'}"
                        >
                            <div
                                class="max-w-[70%] {message.sender_id ===
                                $user?.id
                                    ? 'bg-primary-600 text-white'
                                    : 'bg-white text-slate-900 border border-slate-200'} rounded-2xl px-4 py-2 shadow-sm"
                            >
                                <p class="text-sm">{message.body}</p>
                                <p
                                    class="text-xs mt-1 {message.sender_id ===
                                    $user?.id
                                        ? 'text-primary-200'
                                        : 'text-slate-400'}"
                                >
                                    {formatTime(message.created_at)}
                                </p>
                            </div>
                        </div>
                    {/each}
                </div>
            </div>

            <!-- Message Input -->
            <div class="bg-white border-t border-slate-200 p-4">
                <form
                    on:submit|preventDefault={handleSubmit}
                    class="flex gap-4 max-w-3xl mx-auto"
                >
                    <input
                        type="text"
                        bind:value={newMessage}
                        placeholder="Type a message..."
                        class="input flex-1"
                    />
                    <button
                        type="submit"
                        disabled={isSending || !newMessage.trim()}
                        class="btn-primary"
                    >
                        <svg
                            class="w-5 h-5"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                        >
                            <path
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                stroke-width="2"
                                d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"
                            />
                        </svg>
                    </button>
                </form>
            </div>
        {:else}
            <div class="flex-1 flex items-center justify-center text-slate-500">
                <div class="text-center">
                    <div class="text-4xl mb-4">💬</div>
                    <p>Select a conversation to start chatting</p>
                </div>
            </div>
        {/if}
    </div>
</div>
