# DevTrack

A full-stack project management application built with **Flutter** and **Node.js**. DevTrack allows developers to create projects, manage tasks, and track progress — all from a clean, modern mobile interface backed by a REST API.

> **This is a portfolio project** demonstrating proficiency in mobile development, backend engineering, database design, Docker containerization, CI/CD pipelines, and automated testing.

---

## What is DevTrack?

DevTrack is a project management app where you can:

- **Register and log in** with a secure account
- **Create projects** and organize them by status (Planning, In Progress, Completed)
- **Add tasks** to each project with priorities, deadlines, and status tracking
- **View a dashboard** with real-time statistics about your projects and tasks
- **Manage everything** from a mobile app that talks to a REST API backend

Think of it as a simplified Jira or Trello — built from scratch to demonstrate real full-stack development skills.

---

## Features

- ✅ User authentication (Register / Login / Logout)
- ✅ JWT-based session management with auto-login
- ✅ Project CRUD (Create, Read, Update, Delete)
- ✅ Task CRUD with priority and status management
- ✅ Dashboard with live statistics
- ✅ Kanban-style task view grouped by status
- ✅ Pull-to-refresh on all data screens
- ✅ Form validation and error handling
- ✅ Confirmation dialogs for destructive actions
- ✅ Docker containerization
- ✅ CI/CD pipelines with GitHub Actions
- ✅ Automated backend tests
- ✅ Flutter static analysis and widget tests

---

## Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Mobile** | Flutter + Dart | Cross-platform mobile application |
| **State Management** | Provider | Reactive UI state management |
| **Backend** | Node.js + Express.js | REST API server |
| **Database** | MongoDB + Mongoose | NoSQL data storage with ODM |
| **Authentication** | JWT + bcrypt | Secure token-based auth with password hashing |
| **Containerization** | Docker + Docker Compose | Reproducible development environment |
| **CI/CD** | GitHub Actions | Automated testing and deployment pipeline |
| **Testing** | Jest + Supertest (backend), Flutter Test (mobile) | Automated test suites |

---

## Architecture

```
┌─────────────────────┐
│   Flutter Mobile App │
│   (Dart / Provider)  │
└──────────┬──────────┘
           │ HTTP / REST API
           ▼
┌─────────────────────┐
│  Node.js + Express   │
│  (REST API Server)   │
└──────────┬──────────┘
           │ Mongoose ODM
           ▼
┌─────────────────────┐
│      MongoDB         │
│  (NoSQL Database)    │
└─────────────────────┘
```

**How it works:**

1. The **Flutter app** sends HTTP requests to the **Node.js backend**
2. The **backend** validates requests, authenticates users via JWT, and performs database operations
3. **MongoDB** stores all data (users, projects, tasks)
4. **Docker Compose** runs the backend and MongoDB together in containers
5. **GitHub Actions** automatically tests code on every push

---

## Project Structure

```
DevTrack/
│
├── mobile/                      # Flutter application
│   ├── lib/
│   │   ├── config/              # Theme and API configuration
│   │   ├── models/              # Data models (User, Project, Task)
│   │   ├── services/            # API communication layer
│   │   ├── providers/           # State management (Provider)
│   │   ├── screens/             # UI screens (11 screens)
│   │   ├── widgets/             # Reusable UI components
│   │   └── main.dart            # App entry point
│   └── test/                    # Flutter tests
│
├── backend/                     # Node.js REST API
│   ├── src/
│   │   ├── config/              # Database connection
│   │   ├── middleware/           # Auth, validation, error handling
│   │   ├── models/              # Mongoose schemas
│   │   ├── routes/              # API route handlers
│   │   ├── app.js               # Express app setup
│   │   └── server.js            # Server entry point
│   ├── tests/                   # Jest test files
│   ├── Dockerfile               # Backend Docker image
│   └── .env.example             # Environment variable template
│
├── .github/workflows/           # CI/CD pipeline definitions
│   ├── ci.yml                   # Continuous Integration
│   └── cd.yml                   # Continuous Deployment
│
├── docker-compose.yml           # Docker services configuration
├── .gitignore
└── README.md                    # This file
```

---

## Prerequisites

Before running the project, make sure you have these installed:

| Tool | Version | Download |
|------|---------|----------|
| **Node.js** | 18+ | [nodejs.org](https://nodejs.org) |
| **Flutter** | 3.x | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| **Docker** (optional) | Latest | [docker.com](https://www.docker.com/get-started) |
| **MongoDB** (if not using Docker) | 7+ | [mongodb.com](https://www.mongodb.com/try/download/community) |
| **Android Studio** (for mobile) | Latest | [developer.android.com](https://developer.android.com/studio) |

---

## Local Setup

### Option 1: Using Docker (Recommended)

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/DevTrack.git
cd DevTrack

# Start backend + MongoDB with Docker
docker compose up --build

# The API will be available at http://localhost:5000
```

### Option 2: Manual Setup

**1. Start the backend:**

```bash
cd backend

# Copy environment template and configure
cp .env.example .env
# Edit .env with your values:
#   PORT=5000
#   MONGODB_URI=mongodb://localhost:27017/devtrack
#   JWT_SECRET=your-secret-key

# Install dependencies
npm install

# Start the server
npm run dev
```

**2. Start the Flutter app:**

```bash
cd mobile

# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

> **Note:** For Android emulator, the API base URL is configured as `http://10.0.2.2:5000/api` (the emulator routes `10.0.2.2` to the host machine's `localhost`). For a physical device, update the URL in `mobile/lib/config/api_config.dart` to your computer's local IP address.

---

## Environment Variables

Create a `.env` file in the `backend/` directory based on `.env.example`:

| Variable | Description | Example |
|----------|-------------|---------|
| `PORT` | Server port | `5000` |
| `MONGODB_URI` | MongoDB connection string | `mongodb://localhost:27017/devtrack` |
| `JWT_SECRET` | Secret key for JWT tokens | `my-super-secret-key-123` |

> ⚠️ **Never commit your `.env` file.** It contains secrets and is excluded by `.gitignore`.

---

## API Endpoints

| Method | Endpoint | Purpose | Auth Required |
|--------|----------|---------|:---:|
| `GET` | `/api/health` | Health check | ❌ |
| `POST` | `/api/auth/register` | Register a new user | ❌ |
| `POST` | `/api/auth/login` | Login and get JWT | ❌ |
| `GET` | `/api/users/me` | Get current user profile | ✅ |
| `GET` | `/api/dashboard` | Get dashboard statistics | ✅ |
| `GET` | `/api/projects` | List all projects | ✅ |
| `POST` | `/api/projects` | Create a project | ✅ |
| `GET` | `/api/projects/:id` | Get project details | ✅ |
| `PUT` | `/api/projects/:id` | Update a project | ✅ |
| `DELETE` | `/api/projects/:id` | Delete a project + tasks | ✅ |
| `GET` | `/api/projects/:id/tasks` | List tasks in a project | ✅ |
| `POST` | `/api/projects/:id/tasks` | Create a task in a project | ✅ |
| `PUT` | `/api/tasks/:id` | Update a task | ✅ |
| `DELETE` | `/api/tasks/:id` | Delete a task | ✅ |

**Authentication:** Send the JWT token in the `Authorization` header:
```
Authorization: Bearer <your-jwt-token>
```

---

## Docker

### What Docker Does in This Project

Docker packages the backend and database into containers so the entire stack runs with a single command — no manual MongoDB installation or configuration needed.

**Services:**
- `backend` — The Node.js API server
- `mongodb` — The MongoDB database with persistent storage

### Commands

```bash
# Start everything (builds the Docker image first)
docker compose up --build

# Start in the background
docker compose up --build -d

# Stop all services
docker compose down

# Stop and remove database data
docker compose down -v
```

---

## CI/CD

### How the Pipeline Works

```
Code Push / Pull Request
        ↓
   GitHub Actions
        ↓
  ┌─────┴─────┐
  ↓            ↓
Backend      Flutter
 Tests      Analysis
  ↓          & Tests
Docker
 Build
  ↓
(Merge to main)
  ↓
CD Pipeline
  ↓
Docker Image
Tagged & Ready
```

### CI Pipeline (`ci.yml`)

Runs automatically on **every push and pull request**:

1. **Backend Tests** — Installs dependencies and runs Jest tests with an in-memory MongoDB
2. **Docker Build** — Verifies the Docker image builds successfully
3. **Flutter Analysis** — Runs `flutter analyze` to catch code issues
4. **Flutter Tests** — Runs widget and unit tests

### CD Pipeline (`cd.yml`)

Runs automatically when code is **merged to main**:

1. Builds the production Docker image
2. Tags it with `latest` and the commit SHA
3. Ready to push to Docker Hub (instructions in the workflow file)

To enable deployment, add these secrets to your GitHub repository:
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

---

## Testing

### Backend Tests

```bash
cd backend
npm test
```

Tests use [Jest](https://jestjs.io/) with [Supertest](https://github.com/visionmedia/supertest) and an **in-memory MongoDB** — no real database needed.

**What's tested:**
- Health endpoint returns correct response
- User registration (success + duplicate + validation)
- User login (success + wrong password + non-existent user)
- Protected endpoint access (no token, invalid token, valid token)

### Flutter Tests

```bash
cd mobile

# Static analysis — checks for code issues
flutter analyze

# Run unit and widget tests
flutter test
```

**What's tested:**
- Model JSON parsing (User, Project, Task)
- Theme helper methods
- Widget rendering (EmptyState, LoadingIndicator, ErrorDisplay, StatCard)

---

## Future Improvements

- 🔔 Real-time notifications with WebSockets
- 🚀 Redis caching for improved performance
- 👥 Team collaboration and shared projects
- 📎 File uploads and attachments
- ☁️ Cloud deployment (AWS/GCP/Azure)
- 🔐 Role-based permissions (Admin, Member, Viewer)
- 📊 Analytics dashboard with charts
- 🔍 Search and filtering
- 📱 Push notifications
- 🧪 End-to-end testing
- 📈 Monitoring and logging (Prometheus, Grafana)

---

## Screenshots

> Screenshots will be added after the app is deployed and running.

| Screen | Description |
|--------|-------------|
| Splash | App branding and auto-login |
| Login | Email/password authentication |
| Register | New account creation |
| Dashboard | Project and task statistics |
| Projects | Project list view |
| Project Detail | Tasks in Kanban-style columns |
| Profile | User info and logout |

---

## Author

**Your Name**

- GitHub: [github.com/YOUR_USERNAME](https://github.com/YOUR_USERNAME)
- LinkedIn: [linkedin.com/in/YOUR_PROFILE](https://linkedin.com/in/YOUR_PROFILE)

---

## License

This project is open source and available under the [MIT License](LICENSE).
