# Contributing to PERN Stack Setup

Thank you for your interest in contributing to PERN Stack Setup! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Process](#contributing-process)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)
- [Release Process](#release-process)

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the maintainers.

## Getting Started

### Prerequisites

- Node.js 16.0.0 or higher
- PostgreSQL 12.0.0 or higher
- Git
- Bash shell (for script development)

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/rosettascript/pern-setup.git
   cd pern-setup
   ```
3. Add the upstream repository:
   ```bash
   git remote add upstream https://github.com/rosettascript/pern-setup.git
   ```

## Development Setup

### Local Development

1. **Install dependencies** (if any):
   ```bash
   npm install
   ```

2. **Make scripts executable**:
   ```bash
   chmod +x run.sh
   chmod +x lib/*.sh
   ```

3. **Test the setup script**:
   ```bash
   ./run.sh --check
   ```

4. **Run validation**:
   ```bash
   bash lib/validator.sh
   ```

### Testing Your Changes

1. **Test with different templates**:
   ```bash
   # Test starter template
   ./run.sh --quick-setup
   # Choose starter template and test the generated project
   
   # Test API-only template
   ./run.sh --custom-setup
   # Choose API-only template and test the generated project
   ```

2. **Validate generated projects**:
   - Check that all dependencies install correctly
   - Verify that development servers start
   - Test database connections
   - Validate security configurations

## Contributing Process

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b bugfix/issue-number
# or
git checkout -b docs/update-readme
```

### 2. Make Your Changes

- Follow the [coding standards](#coding-standards)
- Add tests for new functionality
- Update documentation as needed
- Ensure all scripts are executable

### 3. Test Your Changes

```bash
# Test the setup script
./run.sh --check

# Test generated templates
./run.sh --quick-setup
# Test the generated project structure and functionality

# Run validation
bash lib/validator.sh
```

### 4. Commit Your Changes

Follow conventional commit format:

```bash
git add .
git commit -m "feat: add new template option for microservices"
# or
git commit -m "fix: resolve database connection issue in Docker setup"
# or
git commit -m "docs: update installation instructions"
```

### 5. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a pull request on GitHub with:
- Clear description of changes
- Reference to any related issues
- Screenshots if UI changes
- Test results

## Coding Standards

### Shell Scripts

- Use `#!/bin/bash` shebang
- Follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- Use meaningful variable names
- Add comments for complex logic
- Use `set -e` for error handling
- Quote variables: `"$VARIABLE"`
- Use `local` for function variables

Example:
```bash
#!/bin/bash

# Function to create project directory
create_project_directory() {
    local project_path="$1"
    local project_name="$2"
    
    if [[ -d "$project_path" ]]; then
        log_error "Directory $project_path already exists"
        return 1
    fi
    
    mkdir -p "$project_path"
    log_success "Created project directory: $project_path"
}
```

### JSON Files

- Use 2-space indentation
- Sort keys alphabetically
- Use consistent naming conventions
- Add comments where helpful (though JSON doesn't support comments natively)

### Documentation

- Use clear, concise language
- Include code examples
- Update both README.md and relevant docs/ files
- Follow markdown best practices

## Testing Guidelines

### Template Testing

Each template should be tested for:

1. **Structure validation**:
   - Correct folder structure
   - All required files present
   - Proper file permissions

2. **Dependency installation**:
   - All packages install without errors
   - No security vulnerabilities
   - Compatible versions

3. **Functionality testing**:
   - Development servers start correctly
   - Database connections work
   - Authentication flows function
   - API endpoints respond

4. **Cross-platform compatibility**:
   - Works on Linux, macOS, and Windows (WSL)
   - Handles different shell environments
   - Proper path handling

### Test Checklist

- [ ] All templates generate without errors
- [ ] Generated projects start successfully
- [ ] Database connections work
- [ ] Security features are properly configured
- [ ] Development tools function correctly
- [ ] Docker containers build and run
- [ ] Tests pass in generated projects

## Documentation

### Required Documentation Updates

When adding new features or templates:

1. **Update README.md**:
   - Add feature to the features list
   - Update usage examples
   - Add new template descriptions

2. **Update docs/ folder**:
   - Add template-specific documentation
   - Update troubleshooting guide
   - Add new configuration options

3. **Update project.json**:
   - Increment version appropriately
   - Add new features to features list
   - Update changelog

### Documentation Standards

- Use clear, concise language
- Include practical examples
- Provide troubleshooting information
- Keep documentation up-to-date with code changes

## Release Process

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (3.0.0): Breaking changes, major new features
- **MINOR** (3.1.0): New features, backward compatible
- **PATCH** (3.0.1): Bug fixes, backward compatible

### Release Checklist

- [ ] All tests pass
- [ ] Documentation is updated
- [ ] Changelog is updated
- [ ] Version numbers are incremented
- [ ] Project.json is updated
- [ ] Release notes are prepared

### Creating a Release

1. Update version numbers in:
   - `project.json`
   - `README.md` (if needed)
   - `docs/CHANGELOG.md`

2. Create a release branch:
   ```bash
   git checkout -b release/v3.0.0
   git push origin release/v3.0.0
   ```

3. Create a pull request for the release
4. After approval, merge and tag:
   ```bash
   git tag v3.0.0
   git push origin v3.0.0
   ```

## Getting Help

- **Issues**: Create an issue for bugs or feature requests
- **Discussions**: Use GitHub Discussions for questions
- **Documentation**: Check the docs/ folder for detailed guides
- **Examples**: Look at existing templates for reference

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation

Thank you for contributing to PERN Stack Setup! 🚀

