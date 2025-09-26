import React, { useState } from 'react';
import axios from 'axios';

function Users({ users, onDataChange }) {
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    password: ''
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [message, setMessage] = useState('');

  const handleInputChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);
    setMessage('');

    try {
      await axios.post('/api/users', formData);
      setMessage('User created successfully!');
      setFormData({ username: '', email: '', password: '' });
      setIsFormOpen(false);
      onDataChange();
    } catch (error) {
      setMessage(error.response?.data?.error || 'Error creating user');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="users">
      <div className="section-header">
        <h2>Users</h2>
        <button
          onClick={() => setIsFormOpen(!isFormOpen)}
          className="add-button"
        >
          {isFormOpen ? 'Cancel' : 'Add User'}
        </button>
      </div>

      {message && (
        <div className={`message ${message.includes('Error') ? 'error' : 'success'}`}>
          {message}
        </div>
      )}

      {isFormOpen && (
        <form onSubmit={handleSubmit} className="user-form">
          <div className="form-group">
            <label htmlFor="username">Username:</label>
            <input
              type="text"
              id="username"
              name="username"
              value={formData.username}
              onChange={handleInputChange}
              required
              minLength="3"
              maxLength="50"
            />
          </div>

          <div className="form-group">
            <label htmlFor="email">Email:</label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              onChange={handleInputChange}
              required
            />
          </div>

          <div className="form-group">
            <label htmlFor="password">Password:</label>
            <input
              type="password"
              id="password"
              name="password"
              value={formData.password}
              onChange={handleInputChange}
              required
              minLength="8"
            />
          </div>

          <button
            type="submit"
            disabled={isSubmitting}
            className="submit-button"
          >
            {isSubmitting ? 'Creating...' : 'Create User'}
          </button>
        </form>
      )}

      <div className="users-list">
        {users.length === 0 ? (
          <p>No users found.</p>
        ) : (
          <div className="users-grid">
            {users.map(user => (
              <div key={user.id} className="user-card">
                <h3>{user.username}</h3>
                <p>{user.email}</p>
                <p className="user-date">
                  Joined: {new Date(user.created_at).toLocaleDateString()}
                </p>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

export default Users;