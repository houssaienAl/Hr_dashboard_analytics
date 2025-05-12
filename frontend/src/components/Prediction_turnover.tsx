import React from 'react';
import Plot from 'react-plotly.js';

const TurnoverDashboard: React.FC = () => {
    // 🔥 Dummy data straight from your screenshots
    const evaluationNo = [0.35, 0.45, 0.55, 0.65, 0.75, 0.85, 0.95];
    const evaluationYes = [0.40, 0.50, 0.60, 0.80, 0.90, 1.00];

    const satisfactionNo = [0.20, 0.40, 0.60, 0.80, 1.00];
    const satisfactionYes = [0.10, 0.30, 0.50, 0.70, 0.90];

    const projectCounts = [2, 3, 4, 5, 6, 7];
    const pctNo = [5.4, 27.0, 26.5, 14.1, 3.6, 0.0];
    const pctYes = [10.5, 0.5, 3.0, 4.0, 5.0, 2.0];

    const depts = [
        'sales', 'accounting', 'hr', 'technical',
        'support', 'management', 'IT', 'product_mng',
        'marketing', 'RandD'
    ];
    const deptCountNo = [4200, 800, 700, 2700, 2200, 1200, 1300, 900, 900, 800];
    const deptCountYes = [1200, 200, 300, 1100, 600, 100, 400, 100, 200, 50];
    const deptTotal = deptCountNo.map((v, i) => v + deptCountYes[i]);

    const salaries = ['low', 'medium', 'high'];
    const salCountNo = [5200, 5100, 1200];
    const salCountYes = [2200, 1300, 100];

    return (
        <div style={{ display: 'grid', gap: 40, padding: 20 }}>
            {/* 1) Evaluation */}

            <Plot
                data={[
                    {
                        x: satisfactionNo,
                        type: 'violin',
                        name: 'No turnover',
                        fillcolor: 'rgba(66,133,244,0.6)',
                        opacity: 0.6
                    },
                    {
                        x: satisfactionYes,
                        type: 'violin',
                        name: 'Turnover',
                        fillcolor: 'rgba(234,67,53,0.6)',
                        opacity: 0.6
                    }
                ]}
                layout={{
                    title: 'Employee Satisfaction Distribution – Turnover V.S. No',
                    xaxis: { title: 'Employee Satisfaction' },
                    yaxis: { title: 'Density' },
                    violinmode: 'overlay'
                } as any}
                style={{ width: '50%', height: 350 }}
            />

            {/* 3) Project Count % */}
            <Plot
                data={[
                    {
                        x: projectCounts,
                        y: pctNo,
                        type: 'bar',
                        name: 'No turnover',
                        marker: { color: 'rgba(66,133,244,0.8)' }
                    },
                    {
                        x: projectCounts,
                        y: pctYes,
                        type: 'bar',
                        name: 'Turnover',
                        marker: { color: 'rgba(234,67,53,0.8)' }
                    }
                ]}
                layout={{
                    title: 'Project Count by Turnover (%)',
                    barmode: 'group',
                    xaxis: { title: 'Project Count' },
                    yaxis: { title: 'Percent' }
                }}
                style={{ width: '50%', height: 350 }}
            />

            {/* 4) Dept Turnover */}
            <Plot
                data={[
                    {
                        x: deptCountNo,
                        y: depts,
                        type: 'bar',
                        name: 'No turnover',
                        orientation: 'h',
                        marker: { color: 'rgba(66,133,244,0.8)' }
                    },
                    {
                        x: deptCountYes,
                        y: depts,
                        type: 'bar',
                        name: 'Turnover',
                        orientation: 'h',
                        marker: { color: 'rgba(234,67,53,0.8)' }
                    }
                ]}
                layout={{
                    title: 'Employee Department Turnover Distribution',
                    barmode: 'group',
                    xaxis: { title: 'Count' },
                    margin: { l: 120 }
                }}
                style={{ width: '50%', height: 350 }}
            />

            {/* 5) Dept Total */}
            <Plot
                data={[
                    {
                        x: depts,
                        y: deptTotal,
                        type: 'bar',
                        marker: { color: 'rgba(76,175,80,0.8)' }
                    }
                ]}
                layout={{
                    title: 'Employee Department Distribution',
                    xaxis: { title: 'Department' },
                    yaxis: { title: 'Count' }
                }}
                style={{ width: '30%', height: 350 }}
            />

            {/* 6) Salary Turnover */}
            <Plot
                data={[
                    {
                        x: salCountNo,
                        y: salaries,
                        type: 'bar',
                        name: 'No turnover',
                        orientation: 'h',
                        marker: { color: 'rgba(66,133,244,0.8)' }
                    },
                    {
                        x: salCountYes,
                        y: salaries,
                        type: 'bar',
                        name: 'Turnover',
                        orientation: 'h',
                        marker: { color: 'rgba(234,67,53,0.8)' }
                    }
                ]}
                layout={{
                    title: 'Employee Salary Turnover Distribution',
                    barmode: 'stack',
                    xaxis: { title: 'Count' },
                    margin: { l: 80 }
                }}
                style={{ width: '100%', height: 350 }}
            />
        </div>
    );
};

export default TurnoverDashboard;
