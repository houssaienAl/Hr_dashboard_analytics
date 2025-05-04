import React, { useState } from 'react';
import './styles/AddEmployee.css';

const AddEmployee: React.FC = () => {
  const [photo, setPhoto] = useState<File | null>(null);
  const [formData, setFormData] = useState({
    Name: '',
    Department: '',
    Salary: '',
    citizendesc: '',
    turnover: '0',
    gender: 'F',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handlePhotoUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setPhoto(e.target.files[0]);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    try {
      const response = await fetch('http://localhost:5000/api/add-employee', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      });

      const result = await response.json();
      if (response.ok) {
        alert(result.message);
        setFormData({
          Name: '',
          Department: '',
          Salary: '',
          citizendesc: '',
          turnover: '0',
          gender: 'F',
        });
      } else {
        alert(result.message || 'Failed to add employee');
      }
    } catch (error) {
      console.error('Error:', error);
      alert('An error occurred while adding the employee');
    }
  };

  return (
    <div className="add-employee-container">
      <h1>Add employee</h1>

      <form className="employee-form" onSubmit={handleSubmit}>


        <div className="form-grid">
          <div className="form-group">
            <label>Name</label>
            <input
              type="integer"
              name="Name"
              value={formData.Name}
              onChange={handleChange}
              placeholder="Enter Name"
            />
          </div>

          <div className="form-group">
            <label>Department</label>
            <input
              type="text"
              name="Department"
              value={formData.Department}
              onChange={handleChange}
              placeholder="Enter your Department"
            />
          </div>

          <div className="form-group">
            <label>Salary</label>
            <input
              type="integer"
              name="Salary"
              value={formData.Salary}
              onChange={handleChange}
              placeholder="Enter How Much You Earn"
            />
          </div>

          <div className="form-group">
            <label>Citizenship</label>
            <input
              type="text"
              name="citizendesc"
              value={formData.citizendesc}
              onChange={handleChange}
              placeholder="Enter the citizenship"
            />
          </div>
          <div className="form-group">
            <label>Turnover</label>
            <select name="turnover" value={formData.turnover} onChange={handleChange}>
              <option>1</option>
              <option>0</option>
            </select>
          </div>

          <div className="form-group">
            <label>Gender</label>
            <select name="gender" value={formData.gender} onChange={handleChange}>
              <option>F</option>
              <option>M</option>

            </select>
          </div>
        </div>

        <button type="submit" className="add-button">
          Add Now
        </button>
      </form>
    </div>
  );
};

export default AddEmployee;
