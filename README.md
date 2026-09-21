# Chintamani Library Management System

A production-ready, cross-platform library management application for **Chintamani Library** (Khalilabad & Mehdawal branches).

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter 3.x + Dart (Android & iOS) |
| Backend API | NestJS 10 + TypeScript |
| Database | PostgreSQL 16 |
| ORM | Prisma |
| State Mgmt | Riverpod |
| Navigation | GoRouter |
| HTTP Client | Dio |

## Project Structure

```
ChintaMani Library/
├── apps/
│   ├── backend/      # NestJS REST API
│   └── mobile/       # Flutter app
├── packages/
│   └── api-types/    # Shared TypeScript types
├── docker-compose.yml
└── .env.example
```

## Quick Start — Backend

### Prerequisites
- Node.js 20+
- Docker Desktop
- PostgreSQL (via Docker)

### 1. Start database
```bash
docker compose up -d postgres pgadmin
```

### 2. Setup backend
```bash
cd apps/backend
cp ../../.env.example .env
# Edit .env with your values

npm install
npx prisma migrate dev
npx prisma db seed
npm run start:dev
```

API runs at: `http://localhost:3000/api/v1`
Swagger docs: `http://localhost:3000/api/docs`
pgAdmin: `http://localhost:5050` (admin@chintamani.com / admin123)

## Quick Start — Flutter App

### Prerequisites
- Flutter 3.22+ installed
- Android Studio or Xcode

### Setup
```bash
cd apps/mobile
flutter pub get
flutter run
```

Update `lib/core/api/api_client.dart` with your backend URL.

## Default Credentials (seed data)

| Role | Email | Password |
|---|---|---|
| Owner | owner@chintamani.com | Admin@1234 |
| Admin (Khalilabad) | admin.khl@chintamani.com | Admin@1234 |
| Staff (Mehdawal) | staff.mhd@chintamani.com | Staff@1234 |

## Branches

- **Chintamani Library – Khalilabad**
- **Chintamani Library – Mehdawal**

## API Documentation

Swagger UI: `http://localhost:3000/api/docs`

## Deployment

See [apps/backend/DEPLOY.md](apps/backend/DEPLOY.md) for Railway/Render deployment guide.

## License

Private — Chintamani Library
