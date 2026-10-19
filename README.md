# DevTrack — Full-Stack Project Management Platform

A production-grade, full-stack developer project management ecosystem built with **Flutter (Dart)**, **Node.js (Express)**, and **MongoDB**. DevTrack elevates everyday task tracking into an enterprise-ready engineering tool featuring an **audit trail activity pipeline**, **dynamic subtask checklists**, **OpenAPI / Swagger documentation**, **deliverables export (JSON & CSV)**, and **executive productivity analytics**.

> 🚀 **Portfolio Highlight**: Demonstrates senior-level full-stack architecture, clean separation of concerns, OpenAPI documentation, automated testing (Jest + Flutter Test), Docker orchestration, CI/CD automation, and modern mobile UX.

---

## 🌟 What Makes DevTrack Stand Out Today?

Unlike basic tutorial CRUD apps, DevTrack implements real-world features modeled after industry standards like **Linear**, **Jira**, and **GitHub Projects**:

### 1. 🔍 Multi-Dimensional Query Engine (Search & Filters)
- **Instant Search**: Full-text regex search across project names, descriptions, and task titles.
- **Dynamic Multi-Filters**: Filter by project categories (`Frontend`, `Backend`, `DevOps`, `Mobile`), task statuses (`Todo`, `In Progress`, `Completed`), priorities (`High`, `Medium`, `Low`), and custom `#tags`.
- **Compound Database Indexing**: Optimized MongoDB compound indexes (`{ user: 1, status: 1, createdAt: -1 }`) ensuring sub-millisecond query performance at scale.

### 2. ✅ Micro-Deliverables Engine (Subtask Checklist)
- **Interactive Checklists**: Break down complex issues into actionable subtasks with atomic status toggling.
- **Dynamic Progress Calculation**: Automatic real-time computation of task completion percentages based on subtask state.
- **Visual Progress Bars**: Animated indicators across Project Cards and Task Views showing `completed / total` deliverables.

### 3. 📜 Immutable Activity Audit Trail (`/api/activity`)
- **Event-Driven Audit Logging**: Every critical action (`PROJECT_CREATED`, `TASK_STATUS_CHANGED`, `SUBTASK_TOGGLED`, `PROJECT_DELETED`) generates an immutable audit record.
- **Chronological Timeline Feed**: Visual activity stream with relative timestamps (`2m ago`, `1h ago`) giving stakeholders full traceability of who changed what and when.

### 4. 📊 Executive Productivity Analytics (`/api/dashboard/analytics`)
- **Productivity Health Score**: Algorithmic score (0–100%) tracking team execution against deadlines.
- **Overdue Task Radar**: Proactive alerts highlighting missed deadlines before they derail sprints.
- **Velocity Tracking**: Compares 7-day task completion volume against previous sprint cycles.
- **Distribution Analytics**: Visual breakdown of tasks by priority level and workflow status.

### 5. 📑 One-Click Deliverables Export
- **Multi-Format Export**: Export any project's deliverables and checklist states into **JSON** (for system backups and API integrations) or **CSV** (for executive spreadsheet reporting).

### 6. 🛡️ Enterprise Security & Hardening
- **Interactive OpenAPI 3.0 Documentation**: Complete interactive Swagger explorer at `/api-docs` with JWT Bearer auth integration.
- **Brute-Force Protection**: Tiered rate-limiting via `express-rate-limit` (strict limits on authentication endpoints to prevent credential stuffing).
- **Security Headers**: `helmet` integration enforcing HTTP security standards (XSS filtering, clickjacking defense).
- **Diagnostics & Health Telemetry**: Live uptime, memory heap allocation, and MongoDB connection monitoring at `/api/health`.

---

## 🛠️ Tech Stack & Architecture

| Layer | Technology | Engineering Significance |
|-------|-----------|--------------------------|
| **Mobile Client** | Flutter 3.x (Dart 3) | Cross-platform Material 3 responsive UI with custom paint and widgets |
| **State Management**| Provider (`ChangeNotifier`) | Reactive, testable state separation following Clean Architecture principles |
| **Backend API** | Node.js + Express.js | Scalable REST API with modular routers, middleware pipelines, and error handling |
| **Database** | MongoDB + Mongoose ODM | Document-oriented storage with schema validation, hooks, and compound indexes |
| **Security** | JWT + bcryptjs + Helmet | Stateless token authorization, cryptographic hashing, and HTTP protection |
| **API Explorer** | Swagger UI + OpenAPI 3.0 | Living documentation and interactive API sandbox at `/api-docs` |
| **Containerization**| Docker + Docker Compose | Multi-container orchestration with persistent MongoDB volume |
| **Testing** | Jest + Supertest (Backend), Flutter Test | In-memory Mongo integration tests + Flutter widget and unit test suites |
| **CI/CD** | GitHub Actions | Automated build, test matrix, and Docker image publishing pipelines |

```
┌────────────────────────────────────────────────────────┐
│               Flutter Mobile Application                │
│    (Material 3 • Provider • Multi-Filter UI • Stream)   │
└───────────────────────────┬────────────────────────────┘
                            │ HTTPS / REST (JWT Bearer)
                            ▼
┌────────────────────────────────────────────────────────┐
│                   Node.js Express API                  │
│  ┌─────────────────┬─────────────────┬──────────────┐  │
│  │ Helmet / CORS   │  Rate Limiting  │ Auth Guard   │  │
│  └────────┬────────┴────────┬────────┴──────┬───────┘  │
│           ▼                 ▼               ▼          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Routers: /auth, /projects, /tasks, /activity    │  │
│  │  /dashboard, /analytics, /health, /api-docs      │  │
│  └──────────────────────────┬───────────────────────┘  │
│                             │ Mongoose ODM Hooks       │
│                             ▼                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  ActivityLogger Service (Async Audit Trail)      │  │
│  └──────────────────────────┬───────────────────────┘  │
└─────────────────────────────┼──────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────┐
│                   MongoDB Database                      │
│   (Users • Projects • Tasks • Subtasks • ActivityLogs) │
│       Compound Indexes: { user: 1, status: 1 }          │
└────────────────────────────────────────────────────────┘
```

---

## 📂 Project Organization

```
DevTrack/
│
├── mobile/                           # Cross-platform Flutter App
│   ├── lib/
│   │   ├── config/                   # Theme tokens, API routing, server settings
│   │   ├── models/                   # User, Project, Task (Subtask), ActivityItem
│   │   ├── services/                 # ApiService (GET, POST, PUT, PATCH, DELETE)
│   │   ├── providers/                # Auth, Project, Task, Dashboard, Activity
│   │   ├── screens/                  # 12 Screens (Dashboard, Projects, Activity, Details, Forms)
│   │   ├── widgets/                  # ProjectCard, TaskCard, StatCard, Loading, Empty
│   │   └── main.dart                 # MultiProvider root & route generator
│   └── test/                         # Model tests, theme tests, widget tests
│
├── backend/                          # Node.js REST API
│   ├── src/
│   │   ├── config/                   # MongoDB database connection
│   │   ├── docs/                     # OpenAPI 3.0 specification (swaggerDoc.js)
│   │   ├── middleware/                # JWT auth, validation, rateLimiters, errorHandler
│   │   ├── models/                   # User, Project, Task (with Subtask), ActivityLog
│   │   ├── routes/                   # auth, projects, tasks, dashboard, activity, health
│   │   ├── services/                 # activityLogger.js
│   │   ├── app.js                    # Express app configuration & middleware pipeline
│   │   └── server.js                 # HTTP listener entry point
│   ├── tests/                        # 20 automated integration tests (Jest + Supertest)
│   └── Dockerfile                    # Multi-stage production container build
│
├── docker-compose.yml                # Docker orchestration (API + MongoDB)
└── README.md                         # Project documentation & interview guide
```

---

## ⚡ Quick Start

### Option 1: Docker (Fastest)

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/DevTrack.git
cd DevTrack

# Spin up API server & MongoDB with persistent volume
docker compose up --build

# Backend & Swagger UI will be live at:
# API Root:   http://localhost:5000
# API Docs:   http://localhost:5000/api-docs
```

### Option 2: Local Manual Setup

**1. Start the Backend:**
```bash
cd backend
npm install
cp .env.example .env
npm run dev
```

**2. Test the API in Browser:**
Open [http://localhost:5000/api-docs](http://localhost:5000/api-docs) to test any endpoint directly via Swagger UI!

**3. Run Mobile App:**
```bash
cd mobile
flutter pub get
flutter run
```

---

## 🧪 Automated Testing

### Backend Test Suite (20 Automated Tests)
Uses **Jest** and an in-memory MongoDB server (`mongodb-memory-server`):
```bash
cd backend
npm test
```
**Test Coverage:**
- ✅ User Registration, validation, duplicate email handling
- ✅ JWT Authentication and invalid token rejections
- ✅ Project Creation, multi-filter search, and status progression
- ✅ Task creation with checklist subtasks and progress recalculation
- ✅ Atomic subtask toggling (`PATCH /api/tasks/:id/subtasks/:subtaskId/toggle`)
- ✅ Deliverables export (JSON and CSV formats)
- ✅ Activity audit trail verification
- ✅ Executive analytics and health score calculations
- ✅ System diagnostics and memory metrics

### Flutter Test Suite (13 Automated Tests)
```bash
cd mobile
flutter test
```
**Test Coverage:**
- ✅ Model JSON serialization (User, Project, Task, Subtask, ActivityItem)
- ✅ Dynamic project metrics and progress calculation
- ✅ Theme status and priority color resolvers
- ✅ UI Widget rendering (StatCard, EmptyState, ErrorDisplay, LoadingIndicator)

---

## 💬 Recruiter & Interview Talking Points

When presenting DevTrack in full-stack engineering interviews:

1. **"How did you approach system design and database relationships?"**
   > *"I designed a flexible document schema in MongoDB with Mongoose. Tasks and their checklist subtasks are linked to projects and users with compound indexing for sub-millisecond query performance. Rather than storing static counts, project progress is calculated dynamically using MongoDB aggregations to guarantee accuracy."*

2. **"What security considerations did you implement?"**
   > *"I implemented stateless JWT authentication with bcrypt password hashing (10 salt rounds). To prevent DoS and brute-force attacks, I integrated tiered rate-limiting: 30 attempts per 15 minutes on auth routes, and 300 requests globally. In addition, Helmet is configured to set critical HTTP defense headers."*

3. **"How did you structure state management in Flutter?"**
   > *"I followed Clean Architecture with Provider for reactive state management. UI screens never talk directly to HTTP clients; they interact with Providers (`ProjectProvider`, `TaskProvider`, `ActivityProvider`), which call typed services with centralized error handling."*

4. **"What features make this feel like a modern developer tool?"**
   > *"Rather than simple CRUD, DevTrack incorporates an immutable event audit trail, subtask checklist with automatic percentage progression, live search and multi-filtering, CSV/JSON data export, and interactive OpenAPI/Swagger documentation at `/api-docs`."*

---

## 📄 License
This project is open-source under the [MIT License](LICENSE).
