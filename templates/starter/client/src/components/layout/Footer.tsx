import React from 'react';

export const Footer: React.FC = () => {
  return (
    <footer className="bg-white border-t">
      <div className="container mx-auto px-4 py-8">
        <div className="flex flex-col md:flex-row justify-between items-center">
          <div className="flex items-center space-x-2 mb-4 md:mb-0">
            <div className="w-6 h-6 bg-blue-600 rounded flex items-center justify-center">
              <span className="text-white font-bold text-sm">P</span>
            </div>
            <span className="text-gray-600">PERN Starter</span>
          </div>
          
          <div className="flex space-x-6 text-sm text-gray-500">
            <a href="#" className="hover:text-gray-700 transition-colors">
              Documentation
            </a>
            <a href="#" className="hover:text-gray-700 transition-colors">
              GitHub
            </a>
            <a href="#" className="hover:text-gray-700 transition-colors">
              Support
            </a>
          </div>
        </div>
        
        <div className="border-t mt-6 pt-6 text-center text-sm text-gray-500">
          <p>&copy; 2025 PERN Starter. Built with React, Express, PostgreSQL, and Node.js.</p>
        </div>
      </div>
    </footer>
  );
};

