import React from 'react';
import './styles/TurnoverPage.css';
import { LineChart, Line, PieChart, Pie, Cell, Tooltip, XAxis, YAxis, CartesianGrid, ResponsiveContainer } from 'recharts';

const TurnoverPage: React.FC = () => {
  const turnoverEvolutionData = [
    { month: 'J', rate: 18 },
    { month: 'M', rate: 14 },
    { month: 'Ar', rate: 13 },
    { month: 'J', rate: 15 },
    { month: 'M', rate: 28 },
    { month: 'J', rate: 32 },
    { month: 'J', rate: 36 },
  ];

  const departureRepartitionData = [
    { name: 'Marketing', value: 30 },
    { name: 'Sales', value: 30 },
    { name: 'Engineering', value: 30 },
    { name: 'Other', value: 10 },
  ];

  const COLORS = ['#4c9aff', '#ff6b81', '#00cec9', '#f0932b'];

  const lastDepartures = [
    { name: 'Julie D.', post: 'Engineer', seniority: '2 years' },
    { name: 'Marc T.', post: 'Sales Associate', seniority: '1 year' },
    { name: 'Emma R.', post: 'Marketing', seniority: '2 years' },
  ];

  return (
    <div className="turnover-container">
      <div className="header">
        <h1>Turnover</h1>
        <select>
          <option>Last 2 months</option>
          <option>Last 6 months</option>
          <option>Last year</option>
        </select>
      </div>

      <div className="top-section">
        <div className="left-top">
          <div className="big-card">
            <p>Turnover rate</p>
            <h2>15.2 %</h2>
          </div>
          <div className="small-cards">
            <div className="small-card">
              <p>Turnover cost</p>
              <h2>200 k</h2>
            </div>
            <div className="small-card">
              <p>Average time before replacement</p>
              <h2>30 Days</h2>
            </div>
          </div>
        </div>

        <div className="right-top turnover-evolution-card">
          <h3>Turnover evolution</h3>
          <ResponsiveContainer width="100%" height={250}>
            <LineChart data={turnoverEvolutionData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="month" />
              <YAxis domain={[0, 40]} tickFormatter={(value) => `${value}%`} />
              <Tooltip formatter={(value: number) => `${value}%`} />
              <Line
                type="monotone"
                dataKey="rate"
                stroke="#000000"
                strokeWidth={2}
                dot={{ fill: '#ffffff', stroke: '#000', strokeWidth: 2, r: 4 }}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className="bottom-section">
        <div className="chart-card departure-repartition">
          <h3>Departure Repartition</h3>
          <div className="departure-content">
            <PieChart width={200} height={150}>
              <Pie
                data={departureRepartitionData}
                cx="50%"
                cy="50%"
                innerRadius={0}
                outerRadius={60}
                fill="#8884d8"
                dataKey="value"
              >
                {departureRepartitionData.map((_, index) => (
                  <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                ))}
              </Pie>
            </PieChart>

            <div className="legend">
              {departureRepartitionData.map((entry, index) => (
                <div className="legend-item" key={`legend-${index}`}>
                  <span
                    className="legend-color"
                    style={{ backgroundColor: COLORS[index % COLORS.length] }}
                  ></span>
                  <span className="legend-text">{entry.name}</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        <div className="chart-card">
          <h3>Departure Motifs</h3>
          <div className="motif">
            <span>Salary</span>
            <div className="bar salary"></div>
          </div>
          <div className="motif">
            <span>Ambiance</span>
            <div className="bar ambiance"></div>
          </div>
          <div className="motif">
            <span>Evolution</span>
            <div className="bar evolution"></div>
          </div>
        </div>

        <div className="chart-card">
          <h3>Last Departure</h3>
          <table className="last-departure-table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Post</th>
                <th>Seniority</th>
              </tr>
            </thead>
            <tbody>
              {lastDepartures.map((dep, idx) => (
                <tr key={idx}>
                  <td>{dep.name}</td>
                  <td>{dep.post}</td>
                  <td>{dep.seniority}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default TurnoverPage;
