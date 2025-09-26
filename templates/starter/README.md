# Full-Stack Application

A modern full-stack application built with React, Node.js, Express, and PostgreSQL.

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ 
- npm 8+
- PostgreSQL 15+
- Redis (optional)

### Development Setup

1. **Clone and setup:**
   ```bash
   git clone https://github.com/rosettascript/pern-setup.git
   cd <your-project>
   chmod +x scripts/development/setup.sh
   ./scripts/development/setup.sh
   ```

2. **Configure environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Start development servers:**
   ```bash
   npm run dev
   ```

4. **Or use Docker:**
   ```bash
   npm run docker:up
   ```

## 📁 Project Structure

```
├── client/                 # React frontend
│   ├── src/
│   │   ├── components/     # Reusable components
│   │   ├── pages/         # Page components
│   │   ├── hooks/         # Custom hooks
│   │   ├── services/      # API services
│   │   ├── types/         # TypeScript types
│   │   └── utils/         # Utility functions
│   └── public/            # Static assets
├── server/                # Node.js backend
│   ├── src/
│   │   ├── controllers/   # Route controllers
│   │   ├── middlewares/ # Express middlewares
│   │   ├── models/        # Database models
│   │   ├── routes/        # API routes
│   │   ├── services/      # Business logic
│   │   └── utils/         # Utility functions
│   └── uploads/           # File uploads
├── shared/                # Shared code
│   ├── types/             # Shared TypeScript types
│   ├── constants/          # Shared constants
│   └── utils/              # Shared utilities
├── docs/                  # Documentation
├── docker/                # Docker configurations
└── scripts/               # Utility scripts
```

## 🛠️ Available Scripts

### Root Level
- `npm run dev` - Start both client and server in development
- `npm run build` - Build all workspaces
- `npm run test` - Run all tests
- `npm run lint` - Lint all workspaces
- `npm run docker:up` - Start with Docker
- `npm run docker:down` - Stop Docker containers

### Client
- `npm run dev --workspace=client` - Start client dev server
- `npm run build --workspace=client` - Build client
- `npm run test --workspace=client` - Run client tests

### Server
- `npm run dev --workspace=server` - Start server dev server
- `npm run build --workspace=server` - Build server
- `npm run test --workspace=server` - Run server tests

## 🐳 Docker Support

The project includes Docker configurations for both development and production:

- **Development:** Uses Docker Compose with hot reloading
- **Production:** Multi-stage builds for optimized images

### Docker Commands

```bash
# Development
docker-compose -f docker-compose.dev.yml up

# Production
docker-compose up

# Build only
docker-compose build
```

## 🧪 Testing

The project includes comprehensive testing setup:

- **Unit Tests:** Jest + React Testing Library
- **Integration Tests:** Supertest for API testing
- **E2E Tests:** (Optional) Playwright or Cypress

```bash
# Run all tests
npm run test

# Run with coverage
npm run test:coverage

# Run specific workspace tests
npm run test --workspace=client
npm run test --workspace=server
```

## 📚 Documentation

- [API Documentation](./docs/api/)
- [Architecture Overview](./docs/architecture/)
- [Deployment Guide](./docs/deployment/)
- [Development Guide](./docs/development/)

## 🔧 Configuration

### Environment Variables

Key environment variables (see `.env.example`):

- `DATABASE_URL` - PostgreSQL connection string
- `JWT_SECRET` - JWT signing secret
- `CORS_ORIGIN` - Allowed CORS origins
- `PORT` - Server port (default: 5000)

### Database

The application uses PostgreSQL with the following features:

- Connection pooling
- Migrations support
- Seed data
- Backup/restore scripts

## 🚀 Deployment

### Production Deployment

1. **Build the application:**
   ```bash
   npm run build
   ```

2. **Use Docker:**
   ```bash
   docker-compose -f docker-compose.prod.yml up
   ```

3. **Or deploy manually:**
   - Set up PostgreSQL database
   - Configure environment variables
   - Run migrations
   - Start the application

### Environment Setup

- **Development:** `NODE_ENV=development`
- **Production:** `NODE_ENV=production`
- **Testing:** `NODE_ENV=test`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.