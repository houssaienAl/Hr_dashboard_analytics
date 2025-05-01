import React, { useState, useEffect } from 'react';
import './styles/HomePage.css';
import {
  LineChart,
  Line,
  PieChart,
  Pie,
  Cell,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
  Legend,
} from 'recharts';
import { MyChart } from './chart1/index';
import { MaleFemaleChart } from './Male-female-count/index';

interface CompanySummary {
  total_employees: number;
  average_age: number;
  average_performance: number;
  average_satisfaction: number;
}

const HomePage: React.FC = () => {
  const [summary, setSummary] = useState<CompanySummary | null>(null);

  useEffect(() => {
    // Fetch data from the Flask API
    fetch('/api/count')
      .then((response) => response.json())
      .then((data) => {
        console.log('Fetched summary data:', data); // Debugging log
        if (data.length > 0) {
          setSummary(data[0]); // Assuming the API returns an array with one object
        }
      })
      .catch((error) => console.error('Error fetching summary data:', error));
  }, []);

  const turnoverData = [
    { name: 'Oct', achieved: 8, target: 10 },
    { name: 'Nov', achieved: 6, target: 9 },
    { name: 'Dec', achieved: 7, target: 9 },
    { name: 'Jan', achieved: 5, target: 8 },
    { name: 'Feb', achieved: 6, target: 8 },
    { name: 'Mar', achieved: 7, target: 8 },
  ];

  const seniorityData = [
    { name: '0-3yrs', count: 20 },
    { name: '3-6yrs', count: 30 },
    { name: '6-9yrs', count: 50 },
    { name: '9yrs+', count: 40 },
  ];

  const absenteeismData = [
    { name: 'Aug', rate: 2 },
    { name: 'Sep', rate: 3 },
    { name: 'Oct', rate: 4 },
    { name: 'Nov', rate: 5 },
    { name: 'Dec', rate: 8 },
    { name: 'Jan', rate: 4 },
    { name: 'Feb', rate: 5 },
    { name: 'Mar', rate: 3 },
    { name: 'Apr', rate: 4 },
    { name: 'May', rate: 2 },
    { name: 'Jun', rate: 6 },
  ];

  const pieData = [
    { name: 'Men', value: 60 },
    { name: 'Women', value: 40 },
  ];

  const COLORS = ['#0088FE', '#FF69B4'];

  return (
    <div className="homepage-container">
      <div className="stats-cards">
        <div className="card blue">
          Total Employees <span>{summary ? summary.total_employees : 'Loading...'}</span>
        </div>
        <div className="card pink">
          Average Age <span>{summary ? summary.average_age : 'Loading...'}</span>
        </div>
        <div className="card green">
          Avg Performance <span>{summary ? summary.average_performance : 'Loading...'}</span>
        </div>
        <div className="card red">
          Avg Job Satisfaction <span>{summary ? summary.average_satisfaction : 'Loading...'}</span>
        </div>
      </div>

      <div className="charts-section">
        <div className="chart-card">
          <h3>Average Salary by Department</h3>

          <MyChart />
        </div>

        <div className="chart-card">
          <h3>Male vs Female Chart</h3>
          <MaleFemaleChart />

        </div>

        <div className="chart-card">
          <h3>Monthly Absenteeism Rate</h3>
          <BarChart width={300} height={200} data={absenteeismData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="name" />
            <YAxis />
            <Tooltip />
            <Bar dataKey="rate" fill="#82ca9d" />
          </BarChart>
        </div>
      </div>

      <div className="seniority-section">
        <h3>Seniority</h3>
        <LineChart width={600} height={200} data={seniorityData}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="name" />
          <YAxis />
          <Tooltip />
          <Line type="monotone" dataKey="count" stroke="#FF965A" />
        </LineChart>
      </div>
    </div>
  );
};

export default HomePage;