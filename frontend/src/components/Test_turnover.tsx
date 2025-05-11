import React, { useState } from 'react';
import axios from 'axios';

const PredictTurnover: React.FC = () => {
    const [formData, setFormData] = useState({
        salary: '',
        empsatisfaction: '',
        engagementsurvey: '',
        specialprojectscount: '',
        dayslatelast30: '',
        absences: '',
    });

    const [result, setResult] = useState<null | { prediction: number; risk_score: number }>(null);
    const [loading, setLoading] = useState(false);

    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        setFormData({ ...formData, [e.target.name]: e.target.value });
    };

    const handleSubmit = async () => {
        setLoading(true);
        try {
            const response = await axios.post('http://localhost:5000/api/predict-turnover', {
                ...formData,
                salary: parseFloat(formData.salary),
                empsatisfaction: parseInt(formData.empsatisfaction),
                engagementsurvey: parseFloat(formData.engagementsurvey),
                specialprojectscount: parseInt(formData.specialprojectscount),
                dayslatelast30: parseInt(formData.dayslatelast30),
                absences: parseInt(formData.absences),
            });

            setResult(response.data);
        } catch (error) {
            console.error('Prediction failed:', error);
            setResult(null);
        }
        setLoading(false);
    };

    return (
        <div style={{ maxWidth: '500px', margin: 'auto' }}>
            <h2>Turnover Prediction</h2>
            {['salary', 'empsatisfaction', 'engagementsurvey', 'specialprojectscount', 'dayslatelast30', 'absences'].map((field) => (
                <div key={field} style={{ marginBottom: '10px' }}>
                    <label style={{ display: 'block' }}>{field}</label>
                    <input
                        type="number"
                        name={field}
                        value={(formData as any)[field]}
                        onChange={handleChange}
                        style={{ width: '100%', padding: '8px' }}
                    />
                </div>
            ))}

            <button onClick={handleSubmit} disabled={loading} style={{ padding: '10px', width: '100%' }}>
                {loading ? 'Predicting...' : 'Predict Turnover Risk'}
            </button>

            {result && (
                <div style={{ marginTop: '20px' }}>
                    <h3>Prediction Result</h3>
                    <p><strong>Will Leave?</strong> {result.prediction === 1 ? 'Yes' : 'No'}</p>
                    <p><strong>Risk Score:</strong> {result.risk_score * 100}%</p>
                </div>
            )}
        </div>
    );
};

export default PredictTurnover;
