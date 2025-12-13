# NomadHire — Freelancers Without Borders

A full-stack freelance marketplace MVP featuring real-time chat, bidding system, milestone payments, and escrow simulation.

## 🚀 Tech Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | SvelteKit, Tailwind CSS |
| **Backend** | Ruby on Rails 8.1 (API mode) |
| **Database** | PostgreSQL 18.x (Works with 14+) |
| **Package Manager** | npm |
| **Real-time** | ActionCable (WebSockets) |
| **Auth** | Devise + devise-jwt (JWT tokens) |
| **Background Jobs** | Sidekiq (Redis) |
| **Payments** | Stripe + Razorpay (test/sandbox mode) |
| **File Storage** | ActiveStorage (Local/S3) |

## 📁 Project Structure

```
NomadHire/
├── frontend/          # SvelteKit application
├── backend/           # Rails API application
├── docs/              # Documentation
├── .env.example       # Template for env variables
└── README.md          # This file
```

## 🛠️ Prerequisites

- **Ruby**: 3.3.10+
- **Rails**: 8.1.1+
- **Node.js**: 18+
- **PostgreSQL**: 14+ (18.1 recommended)

## 🏃 Quick Start

### 1. Clone and Setup Environment

```bash
git clone <repository-url>
cd NomadHire
```

### 2. Backend Setup (Rails API)

Navigate to the backend directory:

```bash
cd backend
```

**Install Dependencies:**

```bash
bundle install
```

**Setup Database:**

1. Ensure PostgreSQL is running and you have a user (default: `postgres`) with password.
2. Copy the environment file:

   ```bash
   cp env.template .env
   # OR on Windows PowerShell:
   # Copy-Item env.template .env
   ```

3. Edit `.env`:
   - Set `DATABASE_URL` or `POSTGRES_PASSWORD` to match your local setup.
   - Example: `POSTGRES_PASSWORD=your_password`

4. Create, Migrate, and Seed:

   ```bash
   bundle exec rails db:create db:migrate db:seed
   ```

**Start the Server:**

*Option A: Windows Helper Script (Recommended)*
If you are running from the `backend` folder:

```powershell
./start_backend.ps1
```

*Option B: Manual Start*

```bash
bundle exec rails s -p 3001
```

The API will be available at `http://localhost:3001`.

### 3. Frontend Setup (SvelteKit)

Open a new terminal and navigate to the frontend directory:

```bash
cd frontend
```

**Install Dependencies:**

```bash
npm install
```

**Start the Development Server:**

```bash
npm run dev
```

The frontend will be available at `http://localhost:5173`.

## 🧪 Test Accounts

The database is seeded with these accounts (password: `password123` for all):

| Role | Email |
|------|-------|
| **Admin** | `admin@test.com` |
| **Client** | `client@test.com` |
| **Freelancer** | `freelancer@test.com` |

## 💳 Test Payment Cards

| Provider | Card Number | Expiry | CVV |
|----------|-------------|--------|-----|
| Stripe | `4242 4242 4242 4242` | Any future | Any 3 digits |
| Razorpay | `4111 1111 1111 1111` | Any future | Any 3 digits |

## ❗ Troubleshooting

### Windows: PostgreSQL "psql not found"

If you get errors about `psql` or `pg_config` not being found:

1. Find your PostgreSQL bin directory (e.g., `C:\Program Files\PostgreSQL\18\bin`).
2. Add it to your System PATH environment variable.
3. Or run in PowerShell:

   ```powershell
   $env:PATH = "C:\Program Files\PostgreSQL\18\bin;$env:PATH"
   ```

### Windows: Backend "Connection Refused"

Ensure your `.env` or `config/database.yml` has the correct `host: localhost` and `username/password` matching your local PostgreSQL installation.

## 📝 License

MIT License
