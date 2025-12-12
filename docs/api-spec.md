# NomadHire API Specification

Base URL: `http://localhost:3001/api/v1`

## Authentication

All authenticated endpoints require the `Authorization` header:

```
Authorization: Bearer <jwt_token>
```

---

## Auth Endpoints

### POST /auth/sign_up

Create a new user account.

**Request:**

```json
{
  "user": {
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "role": "client"
  }
}
```

**Response (201):**

```json
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "client"
  },
  "token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

### POST /auth/sign_in

Authenticate and receive JWT token.

**Request:**

```json
{
  "user": {
    "email": "john@example.com",
    "password": "password123"
  }
}
```

**Response (200):**

```json
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "client"
  },
  "token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

### GET /auth/me

Get current authenticated user.

**Response (200):**

```json
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "client",
    "bio": "Product manager...",
    "skills": ["project-management", "agile"],
    "hourly_rate": 75.00,
    "location": "San Francisco, CA",
    "avatar_url": "https://...",
    "rating_cache": 4.8
  }
}
```

---

## Users Endpoints

### GET /users/:id

Get public user profile.

**Response (200):**

```json
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "role": "freelancer",
    "bio": "Full-stack developer...",
    "skills": ["react", "nodejs", "postgresql"],
    "hourly_rate": 85.00,
    "location": "New York, NY",
    "avatar_url": "https://...",
    "rating_cache": 4.9
  }
}
```

### PATCH /users/:id

Update user profile. *(Authenticated, own profile only)*

**Request:**

```json
{
  "user": {
    "bio": "Updated bio...",
    "skills": ["react", "svelte"],
    "hourly_rate": 90.00
  }
}
```

### GET /search/freelancers

Search freelancers by skills and criteria.

**Query Parameters:**

- `skill` - Filter by skill (can be multiple)
- `min_rate` - Minimum hourly rate
- `max_rate` - Maximum hourly rate
- `location` - Location search
- `q` - Keyword search

**Example:** `/search/freelancers?skill=react&skill=nodejs&max_rate=100`

---

## Jobs Endpoints

### GET /jobs

List all open jobs with filtering.

**Query Parameters:**

- `skill` - Filter by required skill
- `budget_min` - Minimum budget
- `budget_max` - Maximum budget
- `budget_type` - "fixed" or "hourly"
- `q` - Keyword search
- `page` - Page number
- `per_page` - Items per page (default: 20)

**Response (200):**

```json
{
  "jobs": [
    {
      "id": 1,
      "title": "Build React Dashboard",
      "description": "Looking for...",
      "budget_min": 5000,
      "budget_max": 8000,
      "budget_type": "fixed",
      "skills": ["react", "typescript"],
      "deadline": "2024-03-01",
      "status": "open",
      "client": {
        "id": 2,
        "name": "Jane Smith",
        "avatar_url": "https://..."
      },
      "bids_count": 5,
      "created_at": "2024-01-15T10:00:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 100
  }
}
```

### POST /jobs

Create a new job posting. *(Client only)*

**Request:**

```json
{
  "job": {
    "title": "Build React Dashboard",
    "description": "Looking for an experienced developer...",
    "budget_min": 5000,
    "budget_max": 8000,
    "budget_type": "fixed",
    "skills": ["react", "typescript"],
    "deadline": "2024-03-01"
  }
}
```

### GET /jobs/:id

Get job details.

### PATCH /jobs/:id

Update job. *(Owner only)*

### DELETE /jobs/:id

Delete job. *(Owner only, no active bids)*

---

## Bids Endpoints

### GET /jobs/:job_id/bids

List bids for a job. *(Client sees all, freelancer sees own)*

### POST /jobs/:job_id/bids

Place a bid on a job. *(Freelancer only)*

**Request:**

```json
{
  "bid": {
    "amount": 6500,
    "cover_letter": "I'm excited to work on this project...",
    "estimated_days": 30
  }
}
```

### POST /bids/:id/accept

Accept a bid. *(Job owner only)*

This creates a Contract and initial Milestone.

**Response (200):**

```json
{
  "contract": {
    "id": 1,
    "job_id": 1,
    "client_id": 2,
    "freelancer_id": 3,
    "total_amount": 6500,
    "status": "active",
    "milestones": [
      {
        "id": 1,
        "title": "Initial Milestone",
        "amount": 6500,
        "status": "pending"
      }
    ]
  }
}
```

### POST /bids/:id/decline

Decline a bid. *(Job owner only)*

### POST /bids/:id/withdraw

Withdraw own bid. *(Bid owner only)*

---

## Contracts Endpoints

### GET /contracts

List user's contracts. *(Authenticated)*

### GET /contracts/:id

Get contract details with milestones.

---

## Milestones Endpoints

### POST /contracts/:contract_id/milestones

Create a new milestone. *(Client only)*

**Request:**

```json
{
  "milestone": {
    "title": "Design Phase",
    "description": "Complete UI/UX designs",
    "amount": 2000,
    "due_date": "2024-02-01"
  }
}
```

### POST /milestones/:id/pay

Initiate payment for milestone. *(Client only)*

**Request:**

```json
{
  "provider": "stripe"
}
```

**Response (200):**

```json
{
  "client_secret": "pi_1234_secret_5678",
  "payment_intent_id": "pi_1234"
}
```

### POST /milestones/:id/complete

Mark milestone as delivered. *(Freelancer only)*

### POST /milestones/:id/release

Release funds to freelancer. *(Client only)*

---

## Payments Endpoints

### POST /webhooks/stripe

Stripe webhook handler. *(No auth, signature verified)*

### POST /webhooks/razorpay

Razorpay webhook handler. *(No auth, signature verified)*

---

## Conversations Endpoints

### GET /conversations

List user's conversations.

### POST /conversations

Start a new conversation.

**Request:**

```json
{
  "recipient_id": 5
}
```

### GET /conversations/:id/messages

Get messages in a conversation.

### POST /conversations/:id/messages

Send a message. *(REST fallback for non-WebSocket)*

---

## Notifications Endpoints

### GET /notifications

Get user's notifications.

### PATCH /notifications/:id/read

Mark notification as read.

### POST /notifications/read_all

Mark all notifications as read.

---

## Reviews Endpoints

### POST /contracts/:contract_id/reviews

Create a review for completed contract.

**Request:**

```json
{
  "review": {
    "rating": 5,
    "comment": "Excellent work, delivered on time!"
  }
}
```

---

## Admin Endpoints

### GET /admin/users

List all users. *(Admin only)*

### PATCH /admin/users/:id

Update user (ban, change role). *(Admin only)*

### GET /admin/jobs

List all jobs. *(Admin only)*

### GET /admin/stats

Get platform statistics. *(Admin only)*

---

## WebSocket (ActionCable)

### Connection

```javascript
const socket = new WebSocket('ws://localhost:3001/cable');
```

### ChatChannel

```javascript
// Subscribe
{ command: 'subscribe', identifier: '{"channel":"ChatChannel","conversation_id":1}' }

// Send message
{ command: 'message', identifier: '...', data: '{"action":"speak","body":"Hello!"}' }

// Typing indicator
{ command: 'message', identifier: '...', data: '{"action":"typing"}' }
```

### NotificationsChannel

```javascript
// Subscribe
{ command: 'subscribe', identifier: '{"channel":"NotificationsChannel"}' }

// Receive notifications
{ type: 'new_notification', notification: {...} }
```

---

## Error Responses

### 401 Unauthorized

```json
{
  "error": "You need to sign in or sign up before continuing."
}
```

### 403 Forbidden

```json
{
  "error": "You are not authorized to perform this action."
}
```

### 404 Not Found

```json
{
  "error": "Resource not found."
}
```

### 422 Unprocessable Entity

```json
{
  "errors": {
    "email": ["has already been taken"],
    "password": ["is too short (minimum is 6 characters)"]
  }
}
```

### 429 Too Many Requests

```json
{
  "error": "Rate limit exceeded. Try again later."
}
```
