# Deployment Guide for Chintamani Library Backend

## Prerequisites
- Node.js 18+
- PostgreSQL Database
- Redis (optional, for throttling)

## Environment Variables
Create a `.env` file in the root of the project with the following keys:
```env
PORT=3000
DATABASE_URL="postgresql://user:password@host:port/dbname?schema=public"
JWT_SECRET="your_super_secret_jwt_key_here"
CORS_ORIGIN="*"
```

## Local Setup
1. Install dependencies:
   ```bash
   npm install
   ```
2. Generate Prisma Client:
   ```bash
   npx prisma generate
   ```
3. Push Schema to Database:
   ```bash
   npx prisma db push
   ```
4. Seed Initial Data (Owner user, branches, plans, etc.):
   ```bash
   npx ts-node prisma/seed.ts
   ```
5. Run locally:
   ```bash
   npm run start:dev
   ```

## Railway Deployment
1. Connect your GitHub repository to Railway.
2. Add a **PostgreSQL** database service in your Railway project.
3. In the backend service, go to **Variables** and link `DATABASE_URL` from the PostgreSQL service.
4. Add `JWT_SECRET` as a custom variable.
5. Set `PORT` to `3000` (Railway automatically detects and assigns if omitted, but good practice).
6. Set the Build Command:
   ```bash
   npm run build && npx prisma generate
   ```
7. Set the Start Command:
   ```bash
   npx prisma db push && npm run start:prod
   ```

## Render Deployment
1. Create a new **Web Service** on Render connected to your repository.
2. Create a new **PostgreSQL** database on Render.
3. In the Web Service Environment variables, copy the Internal Database URL to `DATABASE_URL`.
4. Set Build Command:
   ```bash
   npm install && npx prisma generate && npm run build
   ```
5. Set Start Command:
   ```bash
   npx prisma db push && node dist/main.js
   ```

## Accessing the API
Once deployed, the Swagger documentation will be available at:
`https://your-domain.com/api/docs`

Default Login:
- **Email:** `owner@chintamani.com`
- **Password:** `Admin@1234`
