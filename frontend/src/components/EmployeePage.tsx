import React, { useState, useEffect } from 'react';
import { PictureAsPdf, Add, Edit, Delete } from '@mui/icons-material';
import './styles/EmployeePage.css';
import { useNavigate } from 'react-router-dom';

interface Employee {
  id: number;
  name: string;
  department: string;
  dateofhire: string;
}

const EmployeePage: React.FC = () => {
  const [employees, setEmployees] = useState<Employee[]>([]);
  const navigate = useNavigate();

  // Fetch data from the Flask endpoint
  useEffect(() => {
    fetch('/api/employee-details')
      .then((response) => response.json())
      .then((data) => {
        console.log('Fetched data:', data); // Debugging log
        setEmployees(data);
      })
      .catch((error) => console.error('Error fetching employee details:', error));
  }, []);

  const handleDelete = (id: number) => {
    setEmployees(employees.filter(emp => emp.id !== id));
  };

  const handleAddEmployee = () => {
    navigate('/AddEmployee');
  };

  return (
    <div className="employee-page-container">
      <div className="employee-header">
        <h1 className="employee-title">Employee</h1>
        <div className="employee-header-buttons">
          <button className="employee-header-button" style={{ color: '#3b82f6', backgroundColor: 'white' }}>
            <span><PictureAsPdf /></span>
          </button>
          <button className="employee-header-button" style={{ color: '#3b82f6', backgroundColor: 'white' }} onClick={handleAddEmployee}>
            <Add />
          </button>
        </div>
      </div>

      <div className="overflow-x-auto">
        <table className="employee-table">
          <thead>
            <tr>
              <th>Id</th>
              <th>Name</th>
              <th>Department</th>
              <th>Date of Hire</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {employees.length === 0 ? (
              <tr>
                <td colSpan={5}>No employees found</td>
              </tr>
            ) : (
              employees.map((emp) => (
                <tr key={emp.id}>
                  <td>{emp.id}</td>
                  <td>{emp.name}</td>
                  <td>{emp.department}</td>
                  <td>{emp.dateofhire}</td>
                  <td>
                    <div className="action-buttons">
                      <button>
                        <Edit />
                      </button>
                      <button onClick={() => handleDelete(emp.id)}>
                        <Delete />
                      </button>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      <div className="pagination">
        <button>Previous</button>
        <button className="active">1</button>
        <button>2</button>
        <button>3</button>
        <button>Next</button>
      </div>

    </div>

  );
};

export default EmployeePage;