import React, { useState, useEffect } from 'react';
import { Routes, Route, Link } from 'react-router-dom';
import axios from 'axios';
import Users from './components/Users';
import Posts from './components/Posts';
import Comments from './components/Comments';
import './App.css';

function App() {
  const [users, setUsers] = useState([]);
  const [posts, setPosts] = useState([]);
  const [comments, setComments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [usersRes, postsRes, commentsRes] = await Promise.all([
        axios.get('/api/users'),
        axios.get('/api/posts'),
        axios.get('/api/comments')
      ]);

      setUsers(usersRes.data);
      setPosts(postsRes.data);
      setComments(commentsRes.data);
      setError(null);
    } catch (err) {
      setError('Failed to fetch data from the server');
      console.error('Error fetching data:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleDataChange = () => {
    fetchData();
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>PERN Stack Starter</h1>
        <p>A modern web application built with PostgreSQL, Express.js, React, and Node.js</p>
      </header>

      <nav className="App-nav">
        <Link to="/" className="nav-link">Dashboard</Link>
        <Link to="/users" className="nav-link">Users</Link>
        <Link to="/posts" className="nav-link">Posts</Link>
        <Link to="/comments" className="nav-link">Comments</Link>
      </nav>

      <main className="App-main">
        {error && (
          <div className="error-message">
            <p>{error}</p>
            <button onClick={fetchData} className="retry-button">
              Retry
            </button>
          </div>
        )}

        {loading ? (
          <div className="loading">Loading...</div>
        ) : (
          <Routes>
            <Route
              path="/"
              element={
                <Dashboard
                  users={users}
                  posts={posts}
                  comments={comments}
                  onDataChange={handleDataChange}
                />
              }
            />
            <Route
              path="/users"
              element={
                <Users
                  users={users}
                  onDataChange={handleDataChange}
                />
              }
            />
            <Route
              path="/posts"
              element={
                <Posts
                  posts={posts}
                  users={users}
                  onDataChange={handleDataChange}
                />
              }
            />
            <Route
              path="/comments"
              element={
                <Comments
                  comments={comments}
                  onDataChange={handleDataChange}
                />
              }
            />
          </Routes>
        )}
      </main>

      <footer className="App-footer">
        <p>&copy; 2023 PERN Stack Starter. Built with modern web technologies.</p>
      </footer>
    </div>
  );
}

function Dashboard({ users, posts, comments, onDataChange }) {
  return (
    <div className="dashboard">
      <h2>Dashboard</h2>

      <div className="stats-grid">
        <div className="stat-card">
          <h3>Users</h3>
          <p className="stat-number">{users.length}</p>
          <Link to="/users" className="stat-link">View Users</Link>
        </div>

        <div className="stat-card">
          <h3>Posts</h3>
          <p className="stat-number">{posts.length}</p>
          <Link to="/posts" className="stat-link">View Posts</Link>
        </div>

        <div className="stat-card">
          <h3>Comments</h3>
          <p className="stat-number">{comments.length}</p>
          <Link to="/comments" className="stat-link">View Comments</Link>
        </div>
      </div>

      <div className="recent-activity">
        <h3>Recent Posts</h3>
        {posts.slice(0, 5).map(post => (
          <div key={post.id} className="activity-item">
            <h4>{post.title}</h4>
            <p>by {post.author_name}</p>
            <p className="activity-date">
              {new Date(post.created_at).toLocaleDateString()}
            </p>
          </div>
        ))}
      </div>
    </div>
  );
}

export default App;