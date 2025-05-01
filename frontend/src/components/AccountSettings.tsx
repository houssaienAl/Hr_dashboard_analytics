import React, { useState } from 'react';
import './styles/AccountSettings.css';

const AccountSettings: React.FC = () => {
  const [isEditing, setIsEditing] = useState(false);
  const [formData, setFormData] = useState({
    fullName: '',
    nickName: '',
    gender: '',
    country: '',
    language: '',
    time: '',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleEditToggle = () => {
    setIsEditing(!isEditing);
  };

  return (
    <div className="account-settings-container">
      <div className="profile-header">
        <div className="profile-info">
          <img src="/profile-placeholder.png" alt="Profile" className="profile-pic" />
          <div>
            <h2>Alexa Rawles</h2>
            <p>alexarawles@gmail.com</p>
          </div>
        </div>
        <button className="edit-button" onClick={handleEditToggle}>
          {isEditing ? 'Save' : 'Edit'}
        </button>
      </div>

      <form className="account-form">
        <div className="form-grid">
          <div className="form-group">
            <label>Full</label>
            <input
              type="text"
              name="fullName"
              placeholder="Your First Name"
              value={formData.fullName}
              onChange={handleChange}
              disabled={!isEditing}
            />
          </div>

          <div className="form-group">
            <label>Nick</label>
            <input
              type="text"
              name="nickName"
              placeholder="Your First Name"
              value={formData.nickName}
              onChange={handleChange}
              disabled={!isEditing}
            />
          </div>

          <div className="form-group">
            <label>Gen</label>
            <select
              name="gender"
              value={formData.gender}
              onChange={handleChange}
              disabled={!isEditing}
            >
              <option value="">Your First Name</option>
              <option value="Male">Male</option>
              <option value="Female">Female</option>
            </select>
          </div>

          <div className="form-group">
            <label>Coun</label>
            <select
              name="country"
              value={formData.country}
              onChange={handleChange}
              disabled={!isEditing}
            >
              <option value="">Select Country</option>
              <option value="USA">USA</option>
              <option value="France">France</option>
            </select>
          </div>

          <div className="form-group">
            <label>Langu</label>
            <select
              name="language"
              value={formData.language}
              onChange={handleChange}
              disabled={!isEditing}
            >
              <option value="">Your First Name</option>
              <option value="English">English</option>
              <option value="French">French</option>
            </select>
          </div>

          <div className="form-group">
            <label>Time</label>
            <select
              name="time"
              value={formData.time}
              onChange={handleChange}
              disabled={!isEditing}
            >
              <option value="">Your First Name</option>
              <option value="GMT+1">GMT+1</option>
              <option value="GMT+2">GMT+2</option>
            </select>
          </div>
        </div>
      </form>

      <div className="email-section">
        <h3>My email Address</h3>
        <div className="email-info">
          <i className="fas fa-envelope"></i>
          <div>
            <p>alexarawles@gmail.com</p>
            <small>1 month ago</small>
          </div>
        </div>
        <button className="add-email-button">
          + Add Email Address
        </button>
      </div>
    </div>
  );
};

export default AccountSettings;
