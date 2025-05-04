import React, { useState } from 'react';
import './styles/LoginPage.css';
import PersonIcon from '@mui/icons-material/Person';
import LockIcon from '@mui/icons-material/Lock';

const LoginPage: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({ email: '', password: '' });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleLogin = async () => {
    setLoading(true);
    try {
      const response = await fetch('http://localhost:5000/api/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      });

      const result = await response.json();
      if (response.ok) {
        alert(`Welcome, ${result.user.name}!`);
        // Redirect to dashboard or another page
        window.location.href = '/dashboard';
      } else {
        alert(result.message || 'Login failed');
      }
    } catch (error) {
      console.error('Error:', error);
      alert('An error occurred during login');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-container">
      <div className="login-box">
        <div className="logologin">
          <img src="/logo.png" alt="Logo" />
        </div>
        <div className="input-group">
          <PersonIcon className="input-icon" />
          <input
            type="text"
            name="email"
            placeholder="EMAIL"
            value={formData.email}
            onChange={handleChange}
          />
        </div>
        <div className="input-group">
          <LockIcon className="input-icon" />
          <input
            type="password"
            name="password"
            placeholder="PASSWORD"
            value={formData.password}
            onChange={handleChange}
          />
        </div>
        <button className="login-button" onClick={handleLogin} disabled={loading}>
          {loading ? <div className="spinner"></div> : 'LOGIN'}
        </button>
        <div className="forgot-password">
          <a href="http://localhost:3000/register">Don't have an account? Register</a>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;