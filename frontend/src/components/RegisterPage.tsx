import React, { useState } from 'react';
import './styles/LoginPage.css';
import PersonIcon from '@mui/icons-material/Person';
import EmailIcon from '@mui/icons-material/Email';
import LockIcon from '@mui/icons-material/Lock';

const RegisterPage: React.FC = () => {
    const [loading, setLoading] = useState(false);
    const [email, setEmail] = useState('');
    const [username, setUsername] = useState(''); // not sent to backend yet
    const [password, setPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const handleRegister = async () => {
        if (!username || !email || !password || !confirmPassword) {
            alert('Please fill all required fields.');
            return;
        }

        if (password !== confirmPassword) {
            alert('Passwords do not match!');
            return;
        }

        setLoading(true);

        try {
            const response = await fetch('http://localhost:5000/api/register', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ name: username, email, password }),
            });

            const data = await response.json();

            if (response.ok) {
                alert('Registration successful!');
                window.location.href = '/login'; // Optional redirect
            } else {
                alert(`Error: ${data.message}`);
            }
        } catch (error) {
            console.error('Registration error:', error);
            alert('An error occurred. Please try again.');
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
                        placeholder="USERNAME"
                        value={username}
                        onChange={(e) => setUsername(e.target.value)}
                    />
                </div>
                <div className="input-group">
                    <EmailIcon className="input-icon" />
                    <input
                        type="email"
                        placeholder="EMAIL"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                    />
                </div>
                <div className="input-group">
                    <LockIcon className="input-icon" />
                    <input
                        type="password"
                        placeholder="PASSWORD"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                    />
                </div>
                <div className="input-group">
                    <LockIcon className="input-icon" />
                    <input
                        type="password"
                        placeholder="CONFIRM PASSWORD"
                        value={confirmPassword}
                        onChange={(e) => setConfirmPassword(e.target.value)}
                    />
                </div>
                <button className="login-button" onClick={handleRegister} disabled={loading}>
                    {loading ? <div className="spinner"></div> : 'REGISTER'}
                </button>
                <div className="forgot-password">
                    <a href="http://localhost:3000/login">Already have an account? Login</a>
                </div>
            </div>
        </div>
    );
};

export default RegisterPage;
