import React, { useEffect, useState } from 'react';

export const EmployeeDetails = (props) => {
    const [employees, setEmployees] = useState([]);

    useEffect(() => {
        // Fetch data from the Flask endpoint
        fetch('/api/employee-details')
            .then((response) => response.json())
            .then((data) => setEmployees(data))
            .catch((error) => console.error('Error fetching employee details:', error));
    }, []);

    return (
        <div>
            <h2>Employee Details</h2>
            <table border="1">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Department</th>
                        <th>ID</th>
                        <th>Date of Hire</th>
                    </tr>
                </thead>
                <tbody>
                    {employees.map((employee, index) => (
                        <tr key={index}>
                            <td>{employee.Name}</td>
                            <td>{employee.Department}</td>
                            <td>{employee.ID}</td>
                            <td>{employee.DateOfHire}</td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
};

export default EmployeeDetails;