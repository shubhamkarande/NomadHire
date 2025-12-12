# NomadHire Architecture

## System Overview

NomadHire is a freelance marketplace built as a monorepo with a decoupled frontend and backend architecture.

```
┌─────────────────────────────────────────────────────────────────────┐
│                           Client Browser                             │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │                    SvelteKit Frontend                            ││
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────┐   ││
│  │  │  Routes  │ │Components│ │  Stores  │ │ WebSocket Client │   ││
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────────────┘   ││
│  └─────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────┘
                              │ HTTPS/WSS │
                              ▼           ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        Rails API Backend                             │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    API Controllers (v1)                       │  │
│  │  ┌────────┐ ┌──────┐ ┌──────┐ ┌────────────┐ ┌───────────┐  │  │
│  │  │  Auth  │ │ Jobs │ │ Bids │ │ Milestones │ │  Payments │  │  │
│  │  └────────┘ └──────┘ └──────┘ └────────────┘ └───────────┘  │  │
│  └──────────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                      ActionCable                              │  │
│  │  ┌─────────────────┐  ┌──────────────────────────────────┐   │  │
│  │  │  ChatChannel    │  │  NotificationsChannel            │   │  │
│  │  └─────────────────┘  └──────────────────────────────────┘   │  │
│  └──────────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                 Services & Integrations                       │  │
│  │  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐  │  │
│  │  │ Stripe Service │  │Razorpay Service│  │ Escrow Service │  │  │
│  │  └────────────────┘  └────────────────┘  └────────────────┘  │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         PostgreSQL                                   │
│  ┌────────┐ ┌──────┐ ┌──────┐ ┌───────────┐ ┌────────────────────┐ │
│  │ Users  │ │ Jobs │ │ Bids │ │ Contracts │ │    Milestones      │ │
│  └────────┘ └──────┘ └──────┘ └───────────┘ └────────────────────┘ │
│  ┌────────────────┐ ┌──────────┐ ┌───────────────┐ ┌───────────┐  │
│  │  Transactions  │ │ Messages │ │ Notifications │ │  Reviews  │  │
│  └────────────────┘ └──────────┘ └───────────────┘ └───────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

## Technology Choices

### Frontend: SvelteKit

- **Why**: Fast, lightweight, excellent DX, built-in routing
- **Styling**: Tailwind CSS for utility-first styling
- **Animations**: GSAP for micro-interactions and hero animations
- **State**: Svelte stores for reactive state management
- **Real-time**: WebSocket client for ActionCable connection

### Backend: Rails API

- **Why**: Rapid development, excellent ecosystem, built-in WebSocket support
- **Auth**: Devise + devise-jwt for JWT-based authentication
- **Authorization**: Pundit for policy-based access control
- **Serialization**: Active Model Serializers for JSON responses
- **Real-time**: ActionCable for WebSocket connections
- **Storage**: ActiveStorage for file uploads

### Database: PostgreSQL

- **Why**: Robust, free, excellent JSON support, full-text search
- **Features used**: JSONB for flexible data, enums, full-text search

### Payments

- **Stripe**: Primary payment processor (test mode)
- **Razorpay**: Alternative for Indian market (sandbox mode)
- **Escrow simulation**: Database-tracked balances for held funds

## Data Flow

### Authentication Flow

```
1. User submits credentials → POST /api/v1/auth/sign_in
2. Backend validates → Returns JWT token
3. Frontend stores token → localStorage/cookie
4. Subsequent requests include → Authorization: Bearer <token>
```

### Job & Bidding Flow

```
1. Client creates job → POST /api/v1/jobs
2. Freelancer browses jobs → GET /api/v1/jobs
3. Freelancer places bid → POST /api/v1/jobs/:id/bids
4. Client receives notification → ActionCable push
5. Client accepts bid → POST /api/v1/bids/:id/accept
6. System creates contract → Contract + Milestone records
```

### Payment Flow

```
1. Client initiates payment → POST /api/v1/milestones/:id/pay
2. Backend creates PaymentIntent → Returns client_secret
3. Frontend confirms payment → Stripe.js/Razorpay.js
4. Payment provider webhook → POST /api/v1/webhooks/stripe
5. Backend updates milestone → Status: paid
6. Freelancer delivers work → Chat/Upload
7. Client releases funds → POST /api/v1/milestones/:id/release
8. System simulates payout → Transaction: released
```

### Real-time Chat Flow

```
1. User opens conversation → Subscribe to ChatChannel
2. User sends message → ActionCable broadcast
3. Recipient receives → Real-time update
4. Message persisted → Database record
```

## Security Measures

1. **JWT Authentication**: Tokens expire, refresh mechanism
2. **CORS Configuration**: Only allow frontend origin
3. **Rate Limiting**: Rack::Attack for API protection
4. **Webhook Verification**: Signature validation for payments
5. **Input Validation**: Strong params + model validations
6. **Authorization**: Pundit policies for resource access
7. **SQL Injection Prevention**: ActiveRecord parameterized queries

## Scalability Considerations

1. **Stateless API**: Horizontal scaling ready
2. **Background Jobs**: Sidekiq for async processing
3. **Caching**: Redis for session/cache storage
4. **CDN**: Static assets can be served via CDN
5. **Database**: Connection pooling, read replicas ready
