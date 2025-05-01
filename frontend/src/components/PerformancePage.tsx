import React from "react";
import "./styles/PerformancePage.css";

import gaugeImage from "./assets/gauge.png";
import targetImage from "./assets/target.png";
import tasksImage from "./assets/tasks.png";

import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  BarChart,
  Bar,
  LabelList,
  Cell
} from "recharts";

const lineData = [
  { name: "Jan", value: 30 },
  { name: "Feb", value: 50 },
  { name: "Mar", value: 40 },
  { name: "Apr", value: 60 },
  { name: "May", value: 50 },
  { name: "Jun", value: 70 },
  { name: "Jul", value: 80 },
];

const barData = [
  { department: "Engineering", performance: 90 },
  { department: "Management", performance: 75 },
  { department: "Finance", performance: 80 },
  { department: "Marketing", performance: 70 },
];

const COLORS = ["#ff6b6b", "#ffa94d", "#69db7c", "#4dabf7"]; // Couleurs personnalisées

const PerformancePage = () => {
  return (
    <div className="performance-container"> {/* Ajouté ici */}
      <div className="performance-page">
        <h1 className="page-title">Performance</h1>

        <div className="top-row">
          <div className="card big-card">
            <p className="card-value-large">82 %</p>
            <img src={gaugeImage} alt="Gauge" className="gauge-img" />
          </div>

          <div className="card big-card">
            <h2 className="card-title">Performance Over Time</h2>
            <div className="chart-container">
              <ResponsiveContainer width="100%" height={200}>
                <LineChart data={lineData}>
                  <CartesianGrid stroke="#ccc" strokeDasharray="5 5" />
                  <XAxis dataKey="name" />
                  <YAxis />
                  <Tooltip />
                  <Line type="monotone" dataKey="value" stroke="#000" strokeWidth={3} dot />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>

        <div className="bottom-row">
          <div className="card small-card">
            <h2 className="card-title">Target Achievement</h2>
            <div className="icon-text">
              <img src={targetImage} alt="Target" className="icon-img" />
              <p className="card-value">96 %</p>
            </div>
          </div>

          <div className="card small-card">
            <h2 className="card-title">Completed Tasks</h2>
            <div className="icon-text">
              <img src={tasksImage} alt="Tasks" className="icon-img" />
              <p className="card-value">120</p>
            </div>
          </div>

          <div className="card small-card">
            <h2 className="card-title">Department Performance</h2>
            <div className="chart-container">
              <ResponsiveContainer width="100%" height={200}>
                <BarChart
                  layout="vertical"
                  data={barData}
                  margin={{ top: 5, right: 20, left: 20, bottom: 5 }}
                >
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis type="number" />
                  <YAxis dataKey="department" type="category" />
                  <Tooltip />
                  <Bar dataKey="performance" barSize={20}>
                    {barData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                    <LabelList dataKey="performance" position="right" />
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default PerformancePage;
