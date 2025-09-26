import React, { useState } from 'react';
import axios from 'axios';

function Comments({ comments, onDataChange }) {
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [formData, setFormData] = useState({
    content: '',
    author_id: '',
    post_id: ''
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
      await axios.post('/api/comments', formData);
      setMessage('Comment created successfully!');
      setFormData({ content: '', author_id: '', post_id: '' });
      setIsFormOpen(false);
      onDataChange();
    } catch (error) {
      setMessage(error.response?.data?.error || 'Error creating comment');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="comments">
      <div className="section-header">
        <h2>Comments</h2>
        <button
          onClick={() => setIsFormOpen(!isFormOpen)}
          className="add-button"
        >
          {isFormOpen ? 'Cancel' : 'Add Comment'}
        </button>
      </div>

      {message && (
        <div className={`message ${message.includes('Error') ? 'error' : 'success'}`}>
          {message}
        </div>
      )}

      {isFormOpen && (
        <form onSubmit={handleSubmit} className="comment-form">
          <div className="form-group">
            <label htmlFor="content">Comment:</label>
            <textarea
              id="content"
              name="content"
              value={formData.content}
              onChange={handleInputChange}
              required
              rows="3"
              maxLength="1000"
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
              {/* This would typically come from a users API */}
              <option value="1">User 1</option>
              <option value="2">User 2</option>
            </select>
          </div>

          <div className="form-group">
            <label htmlFor="post_id">Post:</label>
            <select
              id="post_id"
              name="post_id"
              value={formData.post_id}
              onChange={handleInputChange}
              required
            >
              <option value="">Select a post</option>
              {/* This would typically come from a posts API */}
              <option value="1">Sample Post 1</option>
              <option value="2">Sample Post 2</option>
            </select>
          </div>

          <button
            type="submit"
            disabled={isSubmitting}
            className="submit-button"
          >
            {isSubmitting ? 'Creating...' : 'Create Comment'}
          </button>
        </form>
      )}

      <div className="comments-list">
        {comments.length === 0 ? (
          <p>No comments found.</p>
        ) : (
          <div className="comments-grid">
            {comments.map(comment => (
              <div key={comment.id} className="comment-card">
                <p className="comment-content">{comment.content}</p>
                <div className="comment-meta">
                  <span>by {comment.author_name}</span>
                  <span>on "{comment.post_title}"</span>
                  <span>{new Date(comment.created_at).toLocaleDateString()}</span>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

export default Comments;