import Plot from 'react-plotly.js';
import React, { useCallback, useEffect, useState } from 'react'


export const Turnover_rate_view = (props) => {
    const [plotData, setPlotData] = useState(null);

    useEffect(() => {
        fetch('/api/turnover_rate_view')
            .then((response) => response.json())
            .then((data) => setPlotData(data));
    }, []);

    if (!plotData) return <div>Loading chart...</div>;

    return (
        <Plot
            data={plotData.data}
            layout={plotData.layout}
        />
    );
};
