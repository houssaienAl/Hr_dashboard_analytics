import Plot from 'react-plotly.js';
import React, { useCallback, useEffect, useState } from 'react'




export const Department_employee = () => {
    const [plotData, setPlotData] = useState(null);

    useEffect(() => {
        fetch('/api/Department_employee')
            .then((response) => response.json())
            .then((data) => setPlotData(data));
    }, []);

    if (!plotData) return <div>Loading male vs female chart...</div>;

    return (
        <Plot
            data={plotData.data}
            layout={plotData.layout}
        />
    );
};
