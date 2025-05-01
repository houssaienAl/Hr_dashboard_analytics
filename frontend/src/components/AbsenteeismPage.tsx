import React from 'react';
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, Legend } from 'recharts';
import './styles/AbsenteeismPage.css';

const absenteeismEvolutionData = [
  { month: 'Jan', rate: 3 },
  { month: 'Feb', rate: 4 },
  { month: 'Mar', rate: 4.5 },
  { month: 'Apr', rate: 5 },
  { month: 'May', rate: 4 },
];

const absencesByTypeData = [
  { name: 'Sickness', value: 60 },
  { name: 'Holiday', value: 40 },
];

const COLORS = ['#5d3fd3', '#7cc4fa'];

const AbsenteeismPage: React.FC = () => {
  return (
    <div className="absenteeism-container">
      <h1 className="absenteeism-title">Absenteeism</h1>

      <div className="absenteeism-top">
        <div className="absenteeism-left">
          <div className="absenteeism-card absenteeism-rate">
            <h2>Absenteeism Rate</h2>
            <div className="rate-values">
              <span className="rate-percentage">4.5%</span>
              <span className="rate-number">320</span>
            </div>
          </div>

          <div className="absenteeism-subcards">
            <div className="absenteeism-card absenteeism-days">
              <h2>Absence Days</h2>
              <div className="days-number">25</div>
            </div>
            <div className="absenteeism-card absenteeism-employees">
              <h2>Absent Employees</h2>
              <div className="employees-number">25</div>
            </div>
          </div>
        </div>

        <div className="absenteeism-card absenteeism-evolution">
          <h2>Absenteeism Evolution</h2>
          <div className="evolution-chart">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={absenteeismEvolutionData}>
                <XAxis dataKey="month" />
                <YAxis />
                <Tooltip />
                <Line type="monotone" dataKey="rate" stroke="#5d3fd3" strokeWidth={2} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>

      <div className="absenteeism-bottom">
        <div className="absenteeism-card absenteeism-by-type">
          <h2>Absences by Type</h2>
          <div className="type-donut">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={absencesByTypeData}
                  dataKey="value"
                  nameKey="name"
                  cx="50%"
                  cy="50%"
                  outerRadius={60}
                  innerRadius={30}
                  fill="#8884d8"
                  label
                >
                  {absencesByTypeData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="type-legend">
            <div><span className="dot sickness"></span> Sickness</div>
            <div><span className="dot holiday"></span> Holiday</div>
          </div>
        </div>

        <div className="absenteeism-card recent-absences">
          <h2>Recent Absences</h2>
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Days</th>
              </tr>
            </thead>
            <tbody>
              <tr><td>Julie D.</td><td>3</td></tr>
              <tr><td>Marc T.</td><td>2</td></tr>
              <tr><td>Emma R.</td><td>1</td></tr>
            </tbody>
          </table>
        </div>

        <div className="absenteeism-card recent-absent-employees">
          <h2>Recent Absent Employees</h2>
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Post</th>
                <th>Type</th>
              </tr>
            </thead>
            <tbody>
              <tr><td>Julie D.</td><td>Engineer</td><td>Sickness</td></tr>
              <tr><td>Marc T.</td><td>Sales Associate</td><td>Holiday</td></tr>
              <tr><td>Emma R.</td><td>Marketing</td><td>Sickness</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default AbsenteeismPage;
