import Plot from 'react-plotly.js';
import React, { useCallback, useEffect, useState } from 'react';

type PlotData = {
  data: any[]; // you can replace `any[]` with Plotly.Data[] if you want stricter typing
  layout: Partial<Plotly.Layout>;
};

type MyChartProps = {
  // if your component expects props, define them here (currently you don't use props)
};

export const MyChart: React.FC<MyChartProps> = (props) => {
  const [plotData, setPlotData] = useState<PlotData | null>(null);

  useEffect(() => {
    fetch('/api/chart')
      .then((response) => response.json())
      .then((data: PlotData) => setPlotData(data));
  }, []);

  if (!plotData) return <div>Loading chart...</div>;

  return (
    <Plot
      data={plotData.data}
      layout={plotData.layout}
    />
  );
};
