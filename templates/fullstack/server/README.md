# Server - Node.js/Express Backend

This is the Node.js/Express backend API built with TypeScript.

## Features

- 🚀 Express.js for the web framework
- 📝 TypeScript for type safety
- 🧪 Jest for testing
- 🔍 ESLint and Prettier for code quality
- 🐳 Docker support for containerization
- 🔄 Nodemon for development

## Getting Started

1. Install dependencies:
   ```bash
   npm install
   ```

2. Set up environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. Start development server:
   ```bash
   npm run dev
   ```

4. Build for production:
   ```bash
   npm run build
   npm start
   ```

## Available Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build TypeScript to JavaScript
- `npm start` - Start production server
- `npm run test` - Run tests
- `npm run lint` - Lint code

## Project Structure

- `src/controllers/` - Route controllers
- `src/middlewares/` - Express middlewares
- `src/models/` - Data models
- `src/routes/` - API routes
- `src/services/` - Business logic services
- `src/types/` - TypeScript type definitions
- `src/utils/` - Utility functions
- `src/config/` - Configuration files

## API Endpoints

- `GET /api/health` - Health check endpoint