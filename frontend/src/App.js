import React, { useEffect, useState } from 'react';
import Plot from 'react-plotly.js';
import { Mychart } from './components/chart1';
import { MaleFemaleChart } from './components/chart2';
import { Department_employee } from './components/Department_employee';
import { Turnover_rate_view } from './components/turnover_rate_view';
import { EmployeeDetails } from './components/display_emp';

const OPTIONS = { dragFree: false, loop: true }
const SLIDE_COUNT = 5
const SLIDES = Array.from(Array(SLIDE_COUNT).keys())



function App() {
  return (
    <div>
      <h1>Dashboard</h1>
      <h2>Chart 1</h2>
      <Mychart />

      <h2>Chart 2</h2>
      <MaleFemaleChart />
      <h2>Chart 3</h2>
      <Department_employee />
      <h2>Chart 4</h2>
      <Turnover_rate_view />
      <EmployeeDetails />
    </div>
  );
}

export default App;
