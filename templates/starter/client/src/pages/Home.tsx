import React from 'react';
import { Link } from 'react-router-dom';
import { clsx } from 'clsx';

export const Home: React.FC = () => {
  return (
    <div className="max-w-6xl mx-auto">
      {/* Hero Section */}
      <div className="text-center py-16">
        <h1 className="text-4xl md:text-6xl font-bold text-gray-900 mb-6">
          Welcome to{' '}
          <span className="text-blue-600">PERN Starter</span>
        </h1>
        
        <p className="text-xl text-gray-600 mb-8 max-w-3xl mx-auto">
          A modern, full-stack template built with PostgreSQL, Express.js, React, and Node.js. 
          Get started with authentication, database integration, and modern development practices.
        </p>
        
        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <Link
            to="/register"
            className={clsx(
              'px-8 py-3 rounded-lg font-semibold text-lg transition-all',
              'bg-blue-600 text-white hover:bg-blue-700 hover:shadow-lg'
            )}
          >
            Get Started
          </Link>
          
          <Link
            to="/login"
            className={clsx(
              'px-8 py-3 rounded-lg font-semibold text-lg transition-all',
              'border-2 border-blue-600 text-blue-600 hover:bg-blue-50'
            )}
          >
            Sign In
          </Link>
        </div>
      </div>

      {/* Features Section */}
      <div className="grid md:grid-cols-3 gap-8 py-16">
        <div className="text-center p-6 bg-white rounded-lg shadow-sm">
          <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center mx-auto mb-4">
            <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
            </svg>
          </div>
          <h3 className="text-xl font-semibold text-gray-900 mb-2">Fast Development</h3>
          <p className="text-gray-600">
            Built with modern tools and best practices for rapid development and deployment.
          </p>
        </div>

        <div className="text-center p-6 bg-white rounded-lg shadow-sm">
          <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center mx-auto mb-4">
            <svg className="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <h3 className="text-xl font-semibold text-gray-900 mb-2">Production Ready</h3>
          <p className="text-gray-600">
            Includes authentication, security, testing, and deployment configurations.
          </p>
        </div>

        <div className="text-center p-6 bg-white rounded-lg shadow-sm">
          <div className="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center mx-auto mb-4">
            <svg className="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
            </svg>
          </div>
          <h3 className="text-xl font-semibold text-gray-900 mb-2">Developer Friendly</h3>
          <p className="text-gray-600">
            Comprehensive documentation, TypeScript support, and modern development tools.
          </p>
        </div>
      </div>

      {/* Tech Stack Section */}
      <div className="py-16 text-center">
        <h2 className="text-3xl font-bold text-gray-900 mb-8">Built With Modern Technologies</h2>
        
        <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
          <div className="flex flex-col items-center p-4">
            <div className="w-16 h-16 bg-blue-100 rounded-lg flex items-center justify-center mb-3">
              <span className="text-2xl font-bold text-blue-600">R</span>
            </div>
            <span className="text-sm font-medium text-gray-700">React 18</span>
          </div>
          
          <div className="flex flex-col items-center p-4">
            <div className="w-16 h-16 bg-green-100 rounded-lg flex items-center justify-center mb-3">
              <span className="text-2xl font-bold text-green-600">E</span>
            </div>
            <span className="text-sm font-medium text-gray-700">Express.js</span>
          </div>
          
          <div className="flex flex-col items-center p-4">
            <div className="w-16 h-16 bg-purple-100 rounded-lg flex items-center justify-center mb-3">
              <span className="text-2xl font-bold text-purple-600">P</span>
            </div>
            <span className="text-sm font-medium text-gray-700">PostgreSQL</span>
          </div>
          
          <div className="flex flex-col items-center p-4">
            <div className="w-16 h-16 bg-orange-100 rounded-lg flex items-center justify-center mb-3">
              <span className="text-2xl font-bold text-orange-600">N</span>
            </div>
            <span className="text-sm font-medium text-gray-700">Node.js</span>
          </div>
        </div>
      </div>
    </div>
  );
};

