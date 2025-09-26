# Troubleshooting Guide

This guide helps you resolve common issues when using the PERN Stack Setup script.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Database Issues](#database-issues)
- [Node.js Issues](#nodejs-issues)
- [Permission Issues](#permission-issues)
- [Port Conflicts](#port-conflicts)
- [Template Issues](#template-issues)
- [Development Tools Issues](#development-tools-issues)
- [Docker Issues](#docker-issues)
- [Performance Issues](#performance-issues)
- [Getting Help](#getting-help)

## Installation Issues

### Script Permission Denied

**Error:** `Permission denied: ./run.sh`

**Solution:**
```bash
chmod +x run.sh
```

### Missing Dependencies

**Error:** `command not found: node` or `command not found: npm`

**Solution:**
```bash
# Install Node.js using nvm (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 18.18.0
nvm use 18.18.0

# Or install using package manager
# Ubuntu/Debian
sudo apt update && sudo apt install nodejs npm

# macOS
brew install node

# Windows
# Download from https://nodejs.org/
```

### Package Installation Fails

**Error:** `npm ERR! network timeout` or `npm ERR! EACCES`

**Solutions:**
```bash
# Clear npm cache
npm cache clean --force

# Use different registry
npm config set registry https://registry.npmjs.org/

# Fix permissions (Linux/macOS)
sudo chown -R $(whoami) ~/.npm
```

## Database Issues

### PostgreSQL Not Running

**Error:** `connection refused` or `database does not exist`

**Solutions:**
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Start PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

# On macOS with Homebrew
brew services start postgresql

# On Windows
# Start PostgreSQL service from Services
```

### Database Connection Failed

**Error:** `FATAL: password authentication failed`

**Solutions:**
```bash
# Reset PostgreSQL password
sudo -u postgres psql
ALTER USER postgres PASSWORD 'newpassword';

# Or create new user
sudo -u postgres createuser -s $USER
sudo -u postgres createdb $USER
```

### Database Already Exists

**Error:** `database "pern_app" already exists`

**Solutions:**
```bash
# Drop existing database
sudo -u postgres psql -c "DROP DATABASE IF EXISTS pern_app;"

# Or use different database name
# Edit .env file with new DB_NAME
```

## Node.js Issues

### Version Conflicts

**Error:** `Node.js version X.X.X is not supported`

**Solutions:**
```bash
# Check current version
node --version

# Use nvm to switch versions
nvm install 18.18.0
nvm use 18.18.0

# Or update Node.js
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# macOS
brew upgrade node
```

### Module Not Found

**Error:** `Cannot find module 'express'`

**Solutions:**
```bash
# Install dependencies
npm install

# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install

# Check package.json exists
ls -la package.json
```

## Permission Issues

### File Permission Denied

**Error:** `EACCES: permission denied`

**Solutions:**
```bash
# Fix ownership
sudo chown -R $USER:$USER /path/to/project

# Fix permissions
chmod -R 755 /path/to/project

# For npm global packages
sudo chown -R $(whoami) ~/.npm
```

### Git Permission Issues

**Error:** `Permission denied (publickey)`

**Solutions:**
```bash
# Generate SSH key
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Add to SSH agent
ssh-add ~/.ssh/id_rsa

# Add to GitHub/GitLab
cat ~/.ssh/id_rsa.pub
# Copy and paste to your Git provider
```

## Port Conflicts

### Port Already in Use

**Error:** `EADDRINUSE: address already in use :::3000`

**Solutions:**
```bash
# Find process using port
lsof -i :3000
lsof -i :5000
lsof -i :5432

# Kill process
kill -9 <PID>

# Or use different ports
# Edit .env file
PORT=5001
CLIENT_PORT=3001
```

### Firewall Issues

**Error:** `Connection refused` from external access

**Solutions:**
```bash
# Ubuntu/Debian
sudo ufw allow 3000
sudo ufw allow 5000

# CentOS/RHEL
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --reload

# macOS
# Check System Preferences > Security & Privacy > Firewall
```

## Template Issues

### Template Copy Failed

**Error:** `cp: cannot stat 'templates/starter/*'`

**Solutions:**
```bash
# Check template directory exists
ls -la templates/

# Fix permissions
chmod -R 755 templates/

# Manual copy
cp -r templates/starter/* /path/to/project/
```

### Missing Template Files

**Error:** `File not found: package.json`

**Solutions:**
```bash
# Check if template was copied correctly
ls -la /path/to/project/

# Re-run template setup
./run.sh
# Choose the same template again
```

## Development Tools Issues

### ESLint Configuration Error

**Error:** `ESLint configuration is invalid`

**Solutions:**
```bash
# Remove and recreate .eslintrc.json
rm .eslintrc.json
npm install --save-dev eslint @eslint/js prettier

# Or use default configuration
npx eslint --init
```

### Prettier Not Working

**Error:** `Prettier not found`

**Solutions:**
```bash
# Install Prettier
npm install --save-dev prettier

# Create .prettierrc
echo '{"semi": true, "singleQuote": true}' > .prettierrc
```

### Jest Tests Failing

**Error:** `Jest encountered an unexpected token`

**Solutions:**
```bash
# Install Jest and dependencies
npm install --save-dev jest @babel/core @babel/preset-env

# Create jest.config.js
echo 'module.exports = { testEnvironment: "node" };' > jest.config.js

# Create babel.config.js
echo 'module.exports = { presets: ["@babel/preset-env"] };' > babel.config.js
```

## Docker Issues

### Docker Not Running

**Error:** `Cannot connect to the Docker daemon`

**Solutions:**
```bash
# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER
# Log out and back in

# On macOS
# Start Docker Desktop application
```

### Docker Build Fails

**Error:** `docker build failed`

**Solutions:**
```bash
# Check Dockerfile syntax
docker build --no-cache .

# Check available space
df -h

# Clean up Docker
docker system prune -a
```

### Container Won't Start

**Error:** `Container exited with code 1`

**Solutions:**
```bash
# Check container logs
docker logs <container_name>

# Run container interactively
docker run -it <image_name> /bin/bash

# Check environment variables
docker run -it <image_name> env
```

## Performance Issues

### Slow Installation

**Symptoms:** npm install takes very long

**Solutions:**
```bash
# Use npm ci for faster installs
npm ci

# Use yarn instead
npm install -g yarn
yarn install

# Increase npm timeout
npm config set timeout 60000
```

### Memory Issues

**Error:** `JavaScript heap out of memory`

**Solutions:**
```bash
# Increase Node.js memory limit
export NODE_OPTIONS="--max-old-space-size=4096"

# Or run with memory limit
node --max-old-space-size=4096 server/index.js
```

### Database Slow Queries

**Solutions:**
```bash
# Check database performance
sudo -u postgres psql -c "SELECT * FROM pg_stat_activity;"

# Add database indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_posts_author_id ON posts(author_id);
```

## Getting Help

### Debug Mode

Run the script with debug information:
```bash
# Enable debug logging
export DEBUG=1
./run.sh

# Or run with verbose output
bash -x run.sh
```

### Log Files

Check log files for detailed error information:
```bash
# Installation logs
cat /tmp/pern-setup-*.log

# Application logs
tail -f logs/error.log
tail -f logs/all.log
```

### System Information

Gather system information for support:
```bash
# System info
uname -a
lsb_release -a  # Linux
sw_vers  # macOS

# Node.js info
node --version
npm --version

# Database info
psql --version
sudo systemctl status postgresql
```

### Common Solutions Checklist

1. ✅ Check system requirements
2. ✅ Verify Node.js version (16.0.0+)
3. ✅ Ensure PostgreSQL is running
4. ✅ Check port availability
5. ✅ Verify file permissions
6. ✅ Clear npm cache if needed
7. ✅ Check firewall settings
8. ✅ Review log files for errors

### Support Channels

- **GitHub Issues:** Create an issue with detailed error information
- **Documentation:** Check the main README.md
- **Community:** Join our Discord/Slack for help
- **Email:** Contact support with system information

### Reporting Issues

When reporting issues, please include:

1. **Operating System:** `uname -a`
2. **Node.js Version:** `node --version`
3. **Error Message:** Complete error output
4. **Log Files:** Relevant log entries
5. **Steps to Reproduce:** What you did before the error
6. **Expected Behavior:** What should have happened
7. **Screenshots:** If applicable

This information helps us provide faster and more accurate support.