import React, { useState } from 'react';
import axios from 'axios';

function Posts({ posts, users, onDataChange }) {
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [formData, setFormData] = useState({
    title: '',
    content: '',
    author_id: ''
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
      await axios.post('/api/posts', formData);
      setMessage('Post created successfully!');
      setFormData({ title: '', content: '', author_id: '' });
      setIsFormOpen(false);
      onDataChange();
    } catch (error) {
      setMessage(error.response?.data?.error || 'Error creating post');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="posts">
      <div className="section-header">
        <h2>Posts</h2>
        <button
          onClick={() => setIsFormOpen(!isFormOpen)}
          className="add-button"
        >
          {isFormOpen ? 'Cancel' : 'Add Post'}
        </button>
      </div>

      {message && (
        <div className={`message ${message.includes('Error') ? 'error' : 'success'}`}>
          {message}
        </div>
      )}

      {isFormOpen && (
        <form onSubmit={handleSubmit} className="post-form">
          <div className="form-group">
            <label htmlFor="title">Title:</label>
            <input
              type="text"
              id="title"
              name="title"
              value={formData.title}
              onChange={handleInputChange}
              required
              maxLength="200"
            />
          </div>

          <div className="form-group">
            <label htmlFor="content">Content:</label>
            <textarea
              id="content"
              name="content"
              value={formData.content}
              onChange={handleInputChange}
              rows="4"
              maxLength="5000"
            />
          </div>

          <div className="form-group">
            <label htmlFor="author_id">Author:</label>
            <select
              id="author_id"
              name="author_id"
              value={formData.author_id}
              onChange={handleInputChange}
              required
            >
              <option value="">Select an author</option>
              {users.map(user => (
                <option key={user.id} value={user.id}>
                  {user.username}
                </option>
              ))}
            </select>
          </div>

          <button
            type="submit"
            disabled={isSubmitting}
            className="submit-button"
          >
            {isSubmitting ? 'Creating...' : 'Create Post'}
          </button>
        </form>
      )}

      <div className="posts-list">
        {posts.length === 0 ? (
          <p>No posts found.</p>
        ) : (
          <div className="posts-grid">
            {posts.map(post => (
              <div key={post.id} className="post-card">
                <h3>{post.title}</h3>
                <p className="post-content">{post.content}</p>
                <div className="post-meta">
                  <span>by {post.author_name}</span>
                  <span>{new Date(post.created_at).toLocaleDateString()}</span>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

export default Posts;