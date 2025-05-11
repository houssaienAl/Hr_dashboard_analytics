import React, { useState, useEffect } from 'react';
import { PictureAsPdf, Add, Edit, Delete } from '@mui/icons-material';
import './styles/EmployeePage.css';
import { useNavigate } from 'react-router-dom';
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';

interface Employee {
  id: number;
  name: string;
  department: string;
  dateofhire: string;
}

const EmployeePage: React.FC = () => {
  const [employees, setEmployees] = useState<Employee[]>([]);
  const navigate = useNavigate();

  useEffect(() => {
    fetch('/api/employee-details')
      .then((response) => response.json())
      .then((data) => {
        console.log('Fetched data:', data);
        setEmployees(data);
      })
      .catch((error) => console.error('Error fetching employee details:', error));
  }, []);

  const handleDelete = async (id: number) => {
    if (!window.confirm('Are you sure you want to delete this employee?')) {
      return;
    }

    try {
      const response = await fetch(`http://localhost:5000/api/delete-employee/${id}`, {
        method: 'DELETE',
      });

      const result = await response.json();
      if (response.ok) {
        alert(result.message);
        setEmployees(employees.filter((emp) => emp.id !== id)); // Update the state to remove the deleted employee
      } else {
        alert(result.message || 'Failed to delete employee');
      }
    } catch (error) {
      console.error('Error deleting employee:', error);
      alert('An error occurred while deleting the employee');
    }
  };

  const handleAddEmployee = () => {
    navigate('/AddEmployee');
  };

  const handleExportPDF = () => {
    const doc = new jsPDF();
    doc.text('Employee List', 14, 16);

    const tableData = employees.map(emp => [
      emp.id,
      emp.name,
      emp.department,
      emp.dateofhire,
    ]);

    autoTable(doc, {
      head: [['ID', 'Name', 'Department', 'Date of Hire']],
      body: tableData,
      startY: 20,
    });

    doc.save('employee_list.pdf');
  };

  return (
    <div className="employee-page-container">
      <div className="employee-header">
        <h1 className="employee-title">Employee</h1>
        <div className="employee-header-buttons">
          <button
            className="employee-header-button"
            style={{ color: '#3b82f6', backgroundColor: 'white' }}
            onClick={handleExportPDF}
          >
            <PictureAsPdf />
          </button>
          <button
            className="employee-header-button"
            style={{ color: '#3b82f6', backgroundColor: 'white' }}
            onClick={handleAddEmployee}
          >
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

                      <button onClick={() => handleDelete(emp.id)}><Delete /></button>
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
