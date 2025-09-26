# 🚀 PERN Setup Documentation

**The Complete Guide to PERN Stack Development**

PERN Setup is your one-stop solution for creating production-ready PostgreSQL + Express.js + React + Node.js applications. This documentation covers everything from quick setup to advanced customization and deployment strategies.

## Features

- 🚀 **Quick Setup**: Automated installation of Node.js, PostgreSQL, and development tools
- 📦 **Multiple Templates (v2.0.0)**: Choose from starter, API-only, full-stack, or microservices templates with modern folder structure
- 🔒 **Security First**: Built-in security configurations, rate limiting, and best practices
- 🛠️ **Development Tools**: ESLint, Prettier, testing frameworks, and Git hooks
- 🐳 **Docker Support**: Containerized development and production deployments
- 🔄 **CI/CD Ready**: GitHub Actions and GitLab CI templates included
- 📚 **Comprehensive Documentation**: Detailed setup and usage guides with v2.0.0 specification

## Quick Start

### Prerequisites

- Linux, macOS, or Windows (WSL recommended)
- curl or wget
- sudo access (for system package installation)

### Installation

1. **Download and run the setup script:**

   ```bash
   curl -fsSL https://raw.githubusercontent.com/rosettascript/pern-setup/main/run.sh -o pern-setup.sh
   chmod +x pern-setup.sh
   ./pern-setup.sh
   ```

2. **Follow the interactive prompts:**

   - Choose installation type (quick, custom, or interactive)
   - Select project template
   - Configure database settings
   - Set up security and environment variables
   - Install development tools

3. **Start developing:**

   ```bash
   cd your-project-name
   npm run dev
   ```

## Project Templates

### 1. Starter Template
- Basic CRUD application with React frontend
- Simple API endpoints for users, posts, and comments
- Modern UI with Tailwind CSS
- Perfect for learning and prototyping

### 2. API-Only Template
- Express.js backend with comprehensive API
- JWT authentication and authorization
- Rate limiting and input validation
- Swagger API documentation
- Ideal for mobile apps or SPAs

### 3. Full-Stack Template
- Complete application with authentication
- User management and profiles
- File uploads and media handling
- Email notifications and payments
- Production-ready features

### 4. Microservices Template
- Multi-service architecture
- API Gateway with load balancing
- Service discovery and communication
- Docker Compose orchestration
- Scalable and maintainable

## System Requirements

### Minimum Requirements
- **RAM**: 2GB
- **Disk Space**: 5GB free space
- **OS**: Linux (Ubuntu 18.04+, CentOS 7+), macOS 10.15+, Windows 10+ (WSL)

### Recommended Requirements
- **RAM**: 4GB+
- **Disk Space**: 10GB+ free space
- **OS**: Ubuntu 20.04+, macOS 11+, Windows 11 (WSL2)

## Installation Options

### Quick Setup (Recommended)
- Installs latest LTS versions of Node.js and PostgreSQL
- Uses sensible defaults for configuration
- Fastest way to get started

### Custom Setup
- Choose specific versions of software
- Configure advanced options
- More control over installation

### Interactive Setup
- Step-by-step guidance through each option
- Detailed explanations of each choice
- Best for learning and understanding

## Database Options

### Local PostgreSQL
- Automatic database and user creation
- Random secure password generation
- Local development optimized

### Docker PostgreSQL
- Containerized database
- Isolated from system
- Easy cleanup and portability

### Remote Database
- Connect to existing PostgreSQL instance
- Cloud database support (AWS RDS, Google Cloud SQL, etc.)
- Production database configuration

## Security Features

- **JWT Authentication**: Secure token-based authentication
- **Rate Limiting**: Protection against brute force attacks
- **Input Validation**: Comprehensive data validation and sanitization
- **Helmet Security**: Security headers and XSS protection
- **CORS Configuration**: Cross-origin request handling
- **Password Hashing**: Secure password storage with bcrypt
- **Environment Variables**: Secure configuration management

## Development Tools

### Code Quality
- **ESLint**: JavaScript linting and code analysis
- **Prettier**: Code formatting and consistency
- **EditorConfig**: Cross-editor configuration

### Testing
- **Jest**: JavaScript testing framework
- **Supertest**: HTTP endpoint testing
- **React Testing Library**: React component testing

### Git Hooks
- **Husky**: Git hooks management
- **lint-staged**: Run linters on staged files
- Pre-commit and pre-push hooks

### Docker Support
- Multi-stage Docker builds
- Docker Compose for local development
- Production-ready containerization

### CI/CD
- GitHub Actions workflows
- GitLab CI pipelines
- Automated testing and deployment

## Configuration Files

### Environment Variables
- `.env`: Main environment configuration
- `.env.example`: Template for required variables
- `.env.development`, `.env.production`: Environment-specific settings

### Package Management
- `package.json`: Node.js dependencies and scripts
- `packages.json`: Template-specific package lists
- `versions.json`: Recommended software versions

### Development Configuration
- `.eslintrc.json`: ESLint configuration
- `.prettierrc`: Prettier configuration
- `.editorconfig`: Editor configuration
- `jest.config.js`: Jest testing configuration

## Usage Examples

### Starting Development Servers

```bash
# Start both frontend and backend
npm run dev

# Start only backend
npm run server

# Start only frontend
npm run client
```

### Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage
```

### Building for Production

```bash
# Build both frontend and backend
npm run build

# Build only frontend
npm run build:client

# Build only backend
npm run build:server
```

### Code Quality Checks

```bash
# Run linter
npm run lint

# Fix linting issues
npm run lint:fix

# Format code
npm run format
```

## Troubleshooting

### Common Issues

1. **Port already in use**
   - Change the port in `.env` file
   - Kill the process using the port: `lsof -ti:3000 | xargs kill -9`

2. **Database connection failed**
   - Check if PostgreSQL is running: `sudo systemctl status postgresql`
   - Verify database credentials in `.env` file
   - Ensure database user exists and has proper permissions

3. **Node modules issues**
   - Delete `node_modules` and `package-lock.json`
   - Run `npm install` to reinstall dependencies

4. **Permission denied errors**
   - Ensure proper file permissions: `chmod +x scripts/*`
   - Check if you have sudo access for system installations

### Getting Help

1. Check the logs in `logs/` directory
2. Review the troubleshooting guide in `docs/troubleshooting.md`
3. Open an issue on the project repository
4. Check the FAQ section below

## FAQ

### Q: Can I use this on Windows?
A: Yes, Windows 10+ with WSL2 is fully supported. Native Windows support is limited.

### Q: What versions of Node.js are supported?
A: Node.js 16+ is supported, with 18+ recommended for the best experience.

### Q: Can I use a different database?
A: The setup is optimized for PostgreSQL, but you can modify the configuration for other databases.

### Q: How do I deploy to production?
A: Use the included Docker configuration or deploy to cloud platforms like Heroku, AWS, or DigitalOcean.

### Q: Can I customize the templates?
A: Yes, all templates are fully customizable and serve as starting points for your projects.

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- 📧 **Email**: support@pern-setup.com
- 💬 **Discord**: [Join our community](https://discord.gg/pern-setup)
- 🐛 **Issues**: [GitHub Issues](https://github.com/rosettascript/pern-setup/issues)
- 📚 **Documentation**: [Full Documentation](https://docs.pern-setup.com)

## Roadmap

- [ ] Windows native support
- [ ] Additional database options (MySQL, MongoDB)
- [ ] More project templates
- [ ] Plugin system for custom configurations
- [ ] Cloud deployment templates
- [ ] Mobile app templates
- [ ] Desktop app templates

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for the latest updates and version history.

---

**Happy coding!** 🎉

Built with ❤️ by the PERN Stack community.