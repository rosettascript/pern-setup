# Project Templates

This guide provides detailed information about the available project templates in the PERN Stack Setup.

## Overview

The PERN Stack Setup includes four main project templates, each designed for different use cases and complexity levels:

1. **Starter Template** - Basic CRUD application for learning
2. **API-Only Template** - Backend-focused API development
3. **Full-Stack Template** - Complete application with advanced features
4. **Microservices Template** - Multi-service architecture

## Template Comparison

| Feature | Starter | API-Only | Full-Stack | Microservices |
|---------|---------|----------|------------|---------------|
| Frontend | ✅ React (v2.0.0) | ❌ | ✅ React (v2.0.0) | ✅ React (v2.0.0) |
| Backend | ✅ Express (v2.0.0) | ✅ Express (v2.0.0) | ✅ Express (v2.0.0) | ✅ Multi-service (v2.0.0) |
| Database | ✅ PostgreSQL | ✅ PostgreSQL | ✅ PostgreSQL | ✅ PostgreSQL |
| Authentication | ❌ | ✅ JWT | ✅ JWT + OAuth | ✅ JWT + OAuth |
| File Uploads | ❌ | ❌ | ✅ | ✅ |
| Real-time | ❌ | ❌ | ✅ Socket.io | ✅ Socket.io |
| Docker | ✅ | ✅ | ✅ | ✅ |
| Testing | ✅ | ✅ | ✅ | ✅ |
| CI/CD | ✅ | ✅ | ✅ | ✅ |
| TypeScript | ✅ | ✅ | ✅ | ✅ |
| Modern Structure | ✅ | ✅ | ✅ | ✅ |

## Starter Template

### Overview
The Starter template is perfect for learning PERN stack development or building simple CRUD applications. It includes a basic React frontend with a clean UI and a simple Express backend with essential API endpoints.

### Features
- **Frontend**: React with Tailwind CSS
- **Backend**: Express.js with basic middleware
- **Database**: PostgreSQL with simple schema
- **API Endpoints**: Users, Posts, Comments
- **UI Components**: Dashboard, forms, and data tables

### Project Structure
```
starter/
├── client/                 # React frontend
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── components/     # React components
│   │   │   ├── Users.js
│   │   │   ├── Posts.js
│   │   │   └── Comments.js
│   │   ├── App.js         # Main app component
│   │   ├── App.css        # Styling
│   │   └── index.js       # Entry point
│   └── package.json
├── server/                 # Express backend
│   ├── index.js           # Main server file
│   └── package.json
└── package.json           # Root package.json
```

### API Endpoints

#### Users
- `GET /api/users` - Get all users
- `POST /api/users` - Create a new user

#### Posts
- `GET /api/posts` - Get all posts
- `POST /api/posts` - Create a new post

#### Comments
- `GET /api/comments` - Get all comments
- `POST /api/comments` - Create a new comment

### Database Schema
```sql
-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Posts table
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    author_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Comments table
CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    author_id INTEGER REFERENCES users(id),
    post_id INTEGER REFERENCES posts(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Usage
1. Start the development servers:
   ```bash
   npm run dev
   ```

2. Open your browser to `http://localhost:3000`

3. The application includes:
   - Dashboard with statistics
   - User management interface
   - Post creation and viewing
   - Comment system

### Customization
The starter template is designed to be easily customizable:

1. **Add new entities**: Create new components and API endpoints
2. **Modify the UI**: Update the Tailwind CSS classes
3. **Extend the database**: Add new tables and relationships
4. **Add authentication**: Implement user login and registration

## API-Only Template

### Overview
The API-Only template is designed for backend-focused development, perfect for mobile applications, SPAs, or when you need a robust API without a frontend.

### Features
- **Authentication**: JWT-based authentication system
- **Rate Limiting**: Protection against abuse
- **Input Validation**: Comprehensive data validation
- **API Documentation**: Swagger/OpenAPI documentation
- **Error Handling**: Structured error responses
- **Logging**: Winston logging system
- **Testing**: Jest and Supertest setup

### Project Structure
```
api-only/
├── server/
│   ├── config/            # Configuration files
│   │   ├── database.js    # Database connection
│   │   └── logger.js      # Logging configuration
│   ├── controllers/       # Route controllers
│   │   ├── auth.js        # Authentication logic
│   │   └── users.js       # User management
│   ├── middleware/        # Custom middleware
│   │   ├── auth.js        # JWT authentication
│   │   ├── validation.js  # Input validation
│   │   └── rateLimit.js   # Rate limiting
│   ├── models/            # Database models
│   │   └── User.js        # User model
│   ├── routes/            # API routes
│   │   ├── auth.js        # Auth routes
│   │   └── users.js       # User routes
│   ├── tests/             # Test files
│   │   ├── auth.test.js   # Auth tests
│   │   └── users.test.js  # User tests
│   ├── utils/             # Utility functions
│   │   └── validation.js  # Validation helpers
│   ├── app.js             # Express app setup
│   ├── index.js           # Server entry point
│   └── package.json
└── package.json
```

### API Endpoints

#### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/refresh` - Token refresh
- `POST /api/auth/logout` - User logout

#### Users
- `GET /api/users` - Get all users (protected)
- `GET /api/users/:id` - Get user by ID (protected)
- `PUT /api/users/:id` - Update user (protected, owner only)
- `DELETE /api/users/:id` - Delete user (protected, owner only)

#### Posts
- `GET /api/posts` - Get all posts (public)
- `GET /api/posts/:id` - Get post by ID (public)
- `POST /api/posts` - Create post (protected)
- `PUT /api/posts/:id` - Update post (protected, owner only)
- `DELETE /api/posts/:id` - Delete post (protected, owner only)

### Security Features
- JWT token authentication
- Password hashing with bcrypt
- Rate limiting (100 requests per 15 minutes)
- Input validation and sanitization
- CORS configuration
- Helmet security headers
- Request logging

### Usage
1. Start the server:
   ```bash
   npm start
   ```

2. Access API documentation at `http://localhost:5000/api-docs`

3. Use the API endpoints with proper authentication headers

### Testing
```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage
```

## Full-Stack Template

### Overview
The Full-Stack template provides a complete application with modern folder structure based on the **v2.0.0 specification**, perfect for production-ready applications. This template implements the comprehensive folder structure defined in `folder-structure-version2.0.0.txt`, ensuring consistency with modern development practices and enterprise-level organization.

### Features
- **Modern Folder Structure**: Organized according to v2.0.0 specification
- **Complete Authentication**: JWT-based authentication system
- **TypeScript Support**: Full TypeScript implementation
- **Comprehensive Testing**: Unit and integration tests
- **Docker Support**: Multi-stage builds and containerization
- **Development Tools**: ESLint, Prettier, and modern tooling
- **Workspace Management**: Monorepo setup with shared dependencies
- **Documentation**: Comprehensive API and architecture documentation

### Project Structure (v2.0.0 Specification)
```
fullstack/
├── client/                 # React frontend with modern structure
│   ├── public/
│   │   ├── favicon.ico
│   │   └── index.html
│   ├── src/
│   │   ├── components/     # Organized component structure
│   │   │   ├── ui/         # Reusable UI components
│   │   │   ├── forms/      # Form components
│   │   │   ├── layout/     # Layout components
│   │   │   ├── features/   # Feature-specific components
│   │   │   └── index.ts
│   │   ├── constants/      # Application constants
│   │   ├── contexts/       # React contexts
│   │   ├── hooks/          # Custom React hooks
│   │   ├── lib/            # Utility libraries
│   │   ├── pages/          # Page components
│   │   ├── services/       # API services
│   │   ├── types/          # TypeScript types
│   │   ├── utils/          # Utility functions
│   │   ├── App.tsx        # Main app component
│   │   ├── main.tsx        # Application entry point
│   │   └── index.css       # Global styles
│   ├── .env.example        # Environment template
│   ├── .eslintrc.json      # ESLint configuration
│   ├── .prettierrc         # Prettier configuration
│   ├── tsconfig.json       # TypeScript configuration
│   ├── vite.config.ts      # Vite configuration
│   ├── tailwind.config.js  # Tailwind CSS configuration
│   └── package.json        # Client dependencies
├── server/                 # Express backend with modern structure
│   ├── src/
│   │   ├── config/         # Configuration files
│   │   ├── controllers/    # Route controllers
│   │   ├── middlewares/    # Express middlewares
│   │   ├── models/         # Database models
│   │   ├── routes/         # API routes
│   │   ├── services/       # Business logic services
│   │   ├── types/          # TypeScript types
│   │   ├── utils/          # Utility functions
│   │   ├── validators/     # Validation schemas
│   │   ├── database/       # Database connection and migrations
│   │   └── app.ts          # Express application setup
│   ├── .env.example        # Environment template
│   ├── .eslintrc.json      # ESLint configuration
│   ├── .prettierrc         # Prettier configuration
│   ├── tsconfig.json       # TypeScript configuration
│   ├── jest.config.js      # Jest testing configuration
│   ├── nodemon.json        # Development server configuration
│   ├── Dockerfile          # Docker configuration
│   └── package.json        # Server dependencies
├── shared/                 # Shared code between client and server
│   ├── src/
│   │   ├── types/          # Shared TypeScript types
│   │   ├── constants/      # Shared constants
│   │   ├── utils/          # Shared utilities
│   │   └── index.ts        # Shared entry point
│   ├── tsconfig.json       # TypeScript configuration
│   └── package.json        # Shared package configuration
├── docs/                   # Comprehensive documentation
│   ├── api/                # API documentation
│   ├── architecture/       # Architecture guides
│   ├── deployment/         # Deployment instructions
│   ├── development/        # Development guides
│   ├── user/               # User documentation
│   └── README.md           # Documentation overview
├── scripts/                # Utility scripts
│   ├── build/              # Build scripts
│   ├── deploy/             # Deployment scripts
│   ├── database/           # Database scripts
│   ├── development/        # Development utilities
│   ├── testing/            # Testing scripts
│   └── utils/              # Utility scripts
├── docker/                 # Docker configurations
│   ├── client/             # Client Docker setup
│   ├── server/             # Server Docker setup
│   ├── database/           # Database Docker setup
│   ├── reverse-proxy/      # Nginx reverse proxy
│   └── docker-compose/     # Docker Compose files
├── .env.example            # Root environment template
├── .gitignore              # Git ignore patterns
├── README.md               # Project documentation
├── package.json            # Root workspace configuration
├── docker-compose.yml      # Production Docker setup
└── docker-compose.dev.yml  # Development Docker setup
```

### Advanced Features

#### Authentication System
- JWT token-based authentication
- OAuth integration (Google, GitHub, Facebook)
- Password reset functionality
- Email verification
- Two-factor authentication support

#### File Management
- Image upload and optimization
- File type validation
- Cloud storage integration (AWS S3, Cloudinary)
- Image resizing and compression

#### Real-time Communication
- Socket.io integration
- Live notifications
- Real-time updates
- Chat functionality

#### Payment Processing
- Stripe integration
- Subscription management
- Invoice generation
- Payment history

#### Email System
- HTML email templates
- Queue-based email sending
- Email tracking
- Unsubscribe functionality

### Usage
1. Configure environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up the database:
   ```bash
   npm run migrate
   ```

4. Start development servers:
   ```bash
   npm run dev
   ```

5. Access the application at `http://localhost:3000`

## Microservices Template

### Overview
The Microservices template provides a multi-service architecture with separate services for different domains, perfect for scalable applications.

### Architecture
- **API Gateway**: Main entry point for all requests
- **Auth Service**: Handles authentication and authorization
- **User Service**: Manages user data and profiles
- **Notification Service**: Handles emails, SMS, and push notifications
- **File Service**: Manages file uploads and storage
- **Shared Services**: Common utilities and configurations

### Features
- **Service Discovery**: Automatic service registration and discovery
- **Load Balancing**: Request distribution across services
- **Circuit Breaker**: Fault tolerance and resilience
- **API Gateway**: Centralized request routing
- **Message Queue**: Asynchronous communication
- **Distributed Logging**: Centralized logging system
- **Health Monitoring**: Service health checks
- **Docker Compose**: Container orchestration
- **Kubernetes Ready**: K8s deployment configurations

### Project Structure
```
microservices/
├── api-gateway/           # Main API gateway
├── services/
│   ├── auth-service/      # Authentication service
│   ├── user-service/      # User management
│   ├── notification-service/ # Notifications
│   ├── file-service/      # File handling
│   └── shared/            # Shared utilities
├── docker-compose.yml     # Docker orchestration
├── kubernetes/            # K8s manifests
├── nginx.conf             # Load balancer config
└── package.json
```

### Services Overview

#### API Gateway
- Routes requests to appropriate services
- Rate limiting and authentication
- Request/response transformation
- Health check aggregation

#### Auth Service
- JWT token management
- OAuth integration
- User sessions
- Password policies

#### User Service
- User profile management
- User preferences
- Avatar handling
- User search

#### Notification Service
- Email sending
- SMS notifications
- Push notifications
- Notification templates

#### File Service
- File upload handling
- Image processing
- File storage
- CDN integration

### Deployment
1. Start all services:
   ```bash
   docker-compose up -d
   ```

2. Access the API gateway at `http://localhost:5000`

3. Monitor service health:
   ```bash
   curl http://localhost:5000/health
   ```

### Scaling
Each service can be scaled independently:

```bash
# Scale user service to 3 instances
docker-compose up -d --scale user-service=3

# Scale with Docker Swarm
docker stack deploy -c docker-compose.yml pern-stack

# Deploy to Kubernetes
kubectl apply -f kubernetes/
```

## Custom Template

### Overview
The Custom template allows you to create a project structure tailored to your specific needs through an interactive setup process.

### Features
- **Interactive Configuration**: Step-by-step project setup
- **Modular Architecture**: Choose which components to include
- **Flexible Structure**: Custom directory layout
- **Plugin System**: Extensible template system

### Usage
1. Select "Custom structure" during setup
2. Choose desired features and components
3. Configure project structure
4. Generate custom template

### Available Options
- Frontend framework (React, Vue, Angular, Svelte)
- Backend framework (Express, Fastify, Koa)
- Database (PostgreSQL, MySQL, MongoDB)
- Authentication method
- UI library
- State management
- Testing framework
- Deployment target

## Template Migration

### Upgrading from Starter to Full-Stack
1. Backup your current project
2. Create a new full-stack project
3. Migrate your custom code and configurations
4. Update dependencies and configurations
5. Test thoroughly before deployment

### Migrating Between Templates
1. Identify the differences between templates
2. Copy your custom code to the new structure
3. Update configuration files
4. Install new dependencies
5. Update build and deployment scripts

## Best Practices

### Template Selection
- Start with Starter template for learning
- Use API-Only for mobile/SPA backends
- Choose Full-Stack for complete applications
- Select Microservices for complex, scalable systems

### Customization Guidelines
- Keep the core structure intact
- Add custom code in designated areas
- Follow the existing patterns and conventions
- Update documentation for custom features
- Test thoroughly after modifications

### Performance Optimization
- Use appropriate template for your use case
- Optimize database queries
- Implement caching strategies
- Monitor application performance
- Scale services as needed

## Support and Resources

- **Documentation**: See individual template README files
- **Examples**: Check the `examples/` directory
- **Community**: Join our Discord for template-specific help
- **Issues**: Report template bugs on GitHub

## Contributing

We welcome template contributions! See our [Contributing Guide](../CONTRIBUTING.md) for details on:

- Creating new templates
- Improving existing templates
- Adding template features
- Template documentation

---

Choose the template that best fits your project needs and start building amazing applications with the PERN stack!