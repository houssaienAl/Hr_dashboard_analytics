// TurnoverDashboard.tsx

import React, { useState, useEffect } from 'react';
import Plot from 'react-plotly.js';

const TurnoverDashboard: React.FC = () => {
    const [projectData, setProjectData] = useState<any[]>([]);
    const [activeTab, setActiveTab] = useState<'satisfaction' | 'project-count' | 'deptTurnover' | 'deptTotal' | 'salary'>('satisfaction');

    // Static chart data
    const satisfactionNo = [0.20, 0.40, 0.60, 0.80, 1.00];
    const satisfactionYes = [0.10, 0.30, 0.50, 0.70, 0.90];

    const projectCounts = [2, 3, 4, 5, 6, 7];
    const pctNo = [5.4, 27.0, 26.5, 14.1, 3.6, 0.0];
    const pctYes = [10.5, 0.5, 3.0, 4.0, 5.0, 2.0];

    const depts = ['sales', 'accounting', 'hr', 'technical', 'support', 'management', 'IT', 'product_mng', 'marketing', 'RandD'];
    const deptCountNo = [4200, 800, 700, 2700, 2200, 1200, 1300, 900, 900, 800];
    const deptCountYes = [1200, 200, 300, 1100, 600, 100, 400, 100, 200, 50];
    const deptTotal = deptCountNo.map((v, i) => v + deptCountYes[i]);

    const salaries = ['low', 'medium', 'high'];
    const salCountNo = [5200, 5100, 1200];
    const salCountYes = [2200, 1300, 100];

    const tabs = [
        { key: 'satisfaction', label: 'Satisfaction Distribution' },
        { key: 'project-count', label: 'Project Count %' },
        { key: 'deptTurnover', label: 'Department Turnover' },
        { key: 'deptTotal', label: 'Department Total' },
        { key: 'salary', label: 'Salary Turnover' },
    ];

    const thStyle = { border: '1px solid #ddd', padding: 8, background: '#f4f4f4' };
    const tdStyle = { border: '1px solid #ddd', padding: 8 };

    // Load table data for dynamic tabs
    useEffect(() => {
        let endpoint: string | null = null;
        switch (activeTab) {
            case 'satisfaction':
                endpoint = 'http://localhost:5000/api/employee-satisfaction';
                break;
            case 'project-count':
                endpoint = 'http://localhost:5000/api/project-count';
                break;
            case 'deptTurnover':
                endpoint = 'http://localhost:5000/api/employee-department';
                break;
            case 'salary':
                endpoint = 'http://localhost:5000/api/employee-salary';
                break;
            default:
                endpoint = null;
        }

        if (endpoint) {
            fetch(endpoint)
                .then(res => res.json())
                .then(data => {
                    // normalize into an array
                    const rows = Array.isArray(data)
                        ? data
                        : data.records && Array.isArray(data.records)
                            ? data.records
                            : [];
                    setProjectData(rows);
                })
                .catch(err => {
                    console.error('Error fetching data:', err);
                    setProjectData([]);  // fallback so .map never crashes
                });
        } else {
            setProjectData([]);
        }
    }, [activeTab]);

    return (
        <div style={{ padding: 20 }}>
            {/* Tabs */}
            <div style={{ display: 'flex', gap: 10, marginBottom: 20 }}>
                {tabs.map(tab => (
                    <button
                        key={tab.key}
                        onClick={() => setActiveTab(tab.key as any)}
                        style={{
                            padding: '10px 20px',
                            cursor: 'pointer',
                            border: '1px solid #ccc',
                            backgroundColor: activeTab === tab.key ? '#4285f4' : '#f1f1f1',
                            color: activeTab === tab.key ? '#fff' : '#000',
                            borderRadius: 4
                        }}
                    >
                        {tab.label}
                    </button>
                ))}
            </div>

            {/* Satisfaction */}
            {activeTab === 'satisfaction' && (
                <>
                    <Plot
                        data={[
                            { x: satisfactionNo, type: 'violin', name: 'No turnover', fillcolor: 'rgba(66,133,244,0.6)', opacity: 0.6 },
                            { x: satisfactionYes, type: 'violin', name: 'Turnover', fillcolor: 'rgba(234,67,53,0.6)', opacity: 0.6 }
                        ]}
                        layout={{ title: 'Employee Satisfaction Distribution – Turnover vs No', xaxis: { title: 'Satisfaction' }, yaxis: { title: 'Density' }, violinmode: 'overlay' } as any}
                        style={{ width: '100%', height: 400 }}
                    />
                    <h3>Employee Details by Satisfaction</h3>
                    <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: 20 }}>
                        <thead>
                            <tr>
                                <th style={thStyle}>ID</th>
                                <th style={thStyle}>Name</th>
                                <th style={thStyle}>Salary</th>
                                <th style={thStyle}>Date of Hire</th>
                                <th style={thStyle}>Satisfaction</th>
                            </tr>
                        </thead>
                        <tbody>
                            {(projectData).map((row, idx) => (
                                <tr key={idx}>
                                    <td style={tdStyle}>{row.id}</td>
                                    <td style={tdStyle}>{row.name}</td>
                                    <td style={tdStyle}>{row.Salary}</td>
                                    <td style={tdStyle}>{row.dateofhire}</td>
                                    <td style={tdStyle}>{row.empsatisfaction}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </>
            )}

            {/* Project Count */}
            {activeTab === 'project-count' && (
                <>
                    <Plot
                        data={[
                            { x: projectCounts, y: pctNo, type: 'bar', name: 'No turnover', marker: { color: 'rgba(66,133,244,0.8)' } },
                            { x: projectCounts, y: pctYes, type: 'bar', name: 'Turnover', marker: { color: 'rgba(234,67,53,0.8)' } }
                        ]}
                        layout={{ title: 'Project Count by Turnover (%)', barmode: 'group', xaxis: { title: 'Project Count' }, yaxis: { title: 'Percent' } }}
                        style={{ width: '100%', height: 400 }}
                    />
                    <h3>Employee Details by Project Count</h3>
                    <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: 20 }}>
                        <thead>
                            <tr>
                                <th style={thStyle}>ID</th>
                                <th style={thStyle}>Name</th>
                                <th style={thStyle}>Department</th>
                                <th style={thStyle}>Date of Hire</th>
                                <th style={thStyle}>Special Projects</th>
                            </tr>
                        </thead>
                        <tbody>
                            {projectData.map((row, idx) => (
                                <tr key={idx}>
                                    <td style={tdStyle}>{row.id}</td>
                                    <td style={tdStyle}>{row.name}</td>
                                    <td style={tdStyle}>{row.department}</td>
                                    <td style={tdStyle}>{row.dateofhire}</td>
                                    <td style={tdStyle}>{row.specialprojectscount}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </>
            )}

            {/* Department Turnover */}
            {activeTab === 'deptTurnover' && (
                <>
                    <Plot
                        data={[
                            { x: deptCountNo, y: depts, type: 'bar', name: 'No turnover', orientation: 'h', marker: { color: 'rgba(66,133,244,0.8)' } },
                            { x: deptCountYes, y: depts, type: 'bar', name: 'Turnover', orientation: 'h', marker: { color: 'rgba(234,67,53,0.8)' } }
                        ]}
                        layout={{ title: 'Employee Department Turnover Distribution', barmode: 'group', xaxis: { title: 'Count' }, margin: { l: 120 } }}
                        style={{ width: '100%', height: 400 }}
                    />
                    <h3>Employee Details by Department</h3>
                    <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: 20 }}>
                        <thead>
                            <tr>
                                <th style={thStyle}>ID</th>
                                <th style={thStyle}>Name</th>
                                <th style={thStyle}>Department</th>
                                <th style={thStyle}>Date of Hire</th>
                            </tr>
                        </thead>
                        <tbody>
                            {projectData.map((row, idx) => (
                                <tr key={idx}>
                                    <td style={tdStyle}>{row.id}</td>
                                    <td style={tdStyle}>{row.name}</td>
                                    <td style={tdStyle}>{row.department}</td>
                                    <td style={tdStyle}>{row.dateofhire}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </>
            )}

            {/* Department Total */}
            {activeTab === 'deptTotal' && (
                <>
                    <Plot
                        data={[{ x: depts, y: deptTotal, type: 'bar', marker: { color: 'rgba(76,175,80,0.8)' } }]}
                        layout={{ title: 'Employee Department Distribution (Total)', xaxis: { title: 'Department' }, yaxis: { title: 'Count' } }}
                        style={{ width: '100%', height: 400 }}
                    />
                    <h3>Department Total Employees</h3>
                    <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: 20 }}>
                        <thead>
                            <tr>
                                <th style={thStyle}>Department</th>
                                <th style={thStyle}>Total Employees</th>
                            </tr>
                        </thead>
                        <tbody>
                            {depts.map((dept, idx) => (
                                <tr key={idx}>
                                    <td style={tdStyle}>{dept}</td>
                                    <td style={tdStyle}>{deptTotal[idx]}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </>
            )}

            {/* Salary */}
            {activeTab === 'salary' && (
                <>
                    <Plot
                        data={[
                            { x: salCountNo, y: salaries, type: 'bar', name: 'No turnover', orientation: 'h', marker: { color: 'rgba(66,133,244,0.8)' } },
                            { x: salCountYes, y: salaries, type: 'bar', name: 'Turnover', orientation: 'h', marker: { color: 'rgba(234,67,53,0.8)' } }
                        ]}
                        layout={{ title: 'Employee Salary Turnover Distribution', barmode: 'stack', xaxis: { title: 'Count' }, margin: { l: 80 } }}
                        style={{ width: '100%', height: 400 }}
                    />
                    <h3>Employee Details by Salary</h3>
                    <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: 20 }}>
                        <thead>
                            <tr>
                                <th style={thStyle}>ID</th>
                                <th style={thStyle}>Name</th>
                                <th style={thStyle}>Salary</th>
                                <th style={thStyle}>Date of Hire</th>
                            </tr>
                        </thead>
                        <tbody>
                            {projectData.map((row, idx) => (
                                <tr key={idx}>
                                    <td style={tdStyle}>{row.id}</td>
                                    <td style={tdStyle}>{row.name}</td>
                                    <td style={tdStyle}>{row.Salary}</td>
                                    <td style={tdStyle}>{row.dateofhire}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </>
            )}
        </div>
    );
};

export default TurnoverDashboard;
