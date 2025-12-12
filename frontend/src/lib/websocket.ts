// WebSocket client for ActionCable
import { api } from './api';

const WS_URL = import.meta.env.VITE_WS_URL || 'ws://localhost:3001/cable';

type MessageHandler = (data: unknown) => void;

interface Channel {
    identifier: string;
    handlers: Map<string, MessageHandler[]>;
}

class WebSocketClient {
    private socket: WebSocket | null = null;
    private channels: Map<string, Channel> = new Map();
    private reconnectAttempts = 0;
    private maxReconnectAttempts = 5;
    private reconnectDelay = 1000;

    connect(): Promise<void> {
        return new Promise((resolve, reject) => {
            const token = api.getToken();
            if (!token) {
                reject(new Error('No auth token'));
                return;
            }

            const url = `${WS_URL}?token=${token}`;
            this.socket = new WebSocket(url);

            this.socket.onopen = () => {
                console.log('WebSocket connected');
                this.reconnectAttempts = 0;
                resolve();
            };

            this.socket.onclose = () => {
                console.log('WebSocket disconnected');
                this.attemptReconnect();
            };

            this.socket.onerror = (error) => {
                console.error('WebSocket error:', error);
                reject(error);
            };

            this.socket.onmessage = (event) => {
                this.handleMessage(event.data);
            };
        });
    }

    private attemptReconnect() {
        if (this.reconnectAttempts < this.maxReconnectAttempts) {
            this.reconnectAttempts++;
            const delay = this.reconnectDelay * Math.pow(2, this.reconnectAttempts - 1);
            console.log(`Reconnecting in ${delay}ms (attempt ${this.reconnectAttempts})`);
            setTimeout(() => this.connect().catch(console.error), delay);
        }
    }

    private handleMessage(data: string) {
        try {
            const message = JSON.parse(data);

            // ActionCable message format
            if (message.type === 'ping') return;
            if (message.type === 'welcome') return;
            if (message.type === 'confirm_subscription') return;

            if (message.identifier && message.message) {
                const channel = this.channels.get(message.identifier);
                if (channel) {
                    const msgType = message.message.type;
                    const handlers = channel.handlers.get(msgType) || [];
                    handlers.forEach(handler => handler(message.message));
                }
            }
        } catch (error) {
            console.error('Failed to parse WebSocket message:', error);
        }
    }

    subscribe(channelName: string, params: Record<string, unknown> = {}): string {
        const identifier = JSON.stringify({ channel: channelName, ...params });

        if (!this.channels.has(identifier)) {
            this.channels.set(identifier, {
                identifier,
                handlers: new Map()
            });

            // Send subscribe command
            if (this.socket?.readyState === WebSocket.OPEN) {
                this.socket.send(JSON.stringify({
                    command: 'subscribe',
                    identifier
                }));
            }
        }

        return identifier;
    }

    unsubscribe(identifier: string) {
        if (this.socket?.readyState === WebSocket.OPEN) {
            this.socket.send(JSON.stringify({
                command: 'unsubscribe',
                identifier
            }));
        }
        this.channels.delete(identifier);
    }

    on(identifier: string, type: string, handler: MessageHandler) {
        const channel = this.channels.get(identifier);
        if (channel) {
            if (!channel.handlers.has(type)) {
                channel.handlers.set(type, []);
            }
            channel.handlers.get(type)!.push(handler);
        }
    }

    off(identifier: string, type: string, handler: MessageHandler) {
        const channel = this.channels.get(identifier);
        if (channel && channel.handlers.has(type)) {
            const handlers = channel.handlers.get(type)!;
            const index = handlers.indexOf(handler);
            if (index > -1) {
                handlers.splice(index, 1);
            }
        }
    }

    send(identifier: string, action: string, data: Record<string, unknown> = {}) {
        if (this.socket?.readyState === WebSocket.OPEN) {
            this.socket.send(JSON.stringify({
                command: 'message',
                identifier,
                data: JSON.stringify({ action, ...data })
            }));
        }
    }

    disconnect() {
        if (this.socket) {
            this.socket.close();
            this.socket = null;
        }
        this.channels.clear();
    }
}

export const ws = new WebSocketClient();
export default ws;
