import React from 'react';
import Plot from 'react-plotly.js';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Layout from './components/Layout';
import LoginPage from './components/LoginPage';
import DashboardPage from './components/DashboardPage';
import HomePage from './components/HomePage';
import EmployeePage from './components/EmployeePage';
import AddEmployee from './components/AddEmployee';
import AccountSettings from './components/AccountSettings';
import RegisterPage from './components/RegisterPage';
import TurnoverPage from './components/TurnoverPage';


const App: React.FC = () => {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Navigate to="/login" replace />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/dashboard" element={<Layout><DashboardPage /></Layout>} />
        <Route path="*" element={<Navigate to="/login" replace />} />
        <Route path="/Home" element={<Layout><HomePage /></Layout>} />
        <Route path="/Employee" element={<Layout><EmployeePage /></Layout>} />
        <Route path="/AddEmployee" element={<Layout><AddEmployee /></Layout>} />
        <Route path="/AccountSettings" element={<Layout><AccountSettings /></Layout>} />
        <Route path="/Register" element={<Layout><RegisterPage /></Layout>} />
        <Route path="/Turnover" element={<Layout><TurnoverPage /></Layout>} />


      </Routes>
    </Router>
  );
};

export default App;
