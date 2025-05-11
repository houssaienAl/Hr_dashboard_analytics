import React, { useEffect, useState } from 'react';

interface Employee {
    id: number;
    Age: number;
    Salary: number;
    prediction: number;
}

const TurnoverPrediction: React.FC = () => {
    const [employees, setEmployees] = useState<Employee[]>([]);

    useEffect(() => {
        fetch('http://localhost:5000/api/predict-turnover')
            .then((res) => res.json())
            .then((data: Employee[]) => setEmployees(data))
            .catch((err) => console.error('Error fetching predictions:', err));
    }, []);

    return (
        <div style={{ padding: '2rem' }}>
            <h2>🔮 Turnover Prediction Dashboard</h2>
            <table style={{ borderCollapse: 'collapse', width: '100%' }}>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Age</th>
                        <th>Salary</th>
                        <th>Prediction</th>
                    </tr>
                </thead>
                <tbody>
                    {employees.map((emp) => (
                        <tr key={emp.id}>
                            <td>{emp.id}</td>
                            <td>{emp.Age}</td>
                            <td>{emp.Salary}</td>
                            <td style={{ color: emp.prediction === 1 ? 'red' : 'green' }}>
                                {emp.prediction === 1 ? 'At Risk 🔴' : 'Safe ✅'}
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
};

export default TurnoverPrediction;
