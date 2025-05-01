import React, { useState } from 'react';
import './styles/LoginPage.css';
import PersonIcon from '@mui/icons-material/Person';
import LockIcon from '@mui/icons-material/Lock';

const LoginPage: React.FC = () => {
  const [loading, setLoading] = useState(false);

  const handleLogin = () => {
    setLoading(true);
    setTimeout(() => {
      setLoading(false);
      alert('Login success!');
    }, 2000);
  };

  return (
    <div className="login-container">
      <div className="login-box">
        <div className="logologin">
          <img src="/logo.png" alt="Logo" />
        </div>
        <div className="input-group">
          <PersonIcon className="input-icon" />
          <input type="text" placeholder="USERNAME" />
        </div>
        <div className="input-group">
          <LockIcon className="input-icon" />
          <input type="password" placeholder="PASSWORD" />
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