#!/bin/bash

# Setup script for full-stack application
echo "Setting up full-stack application..."

# Install dependencies
npm install

# Setup environment files
cp .env.example .env
cp client/.env.example client/.env
cp server/.env.example server/.env

echo "Setup complete!"