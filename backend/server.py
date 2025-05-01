from flask import Flask, jsonify
import pandas as pd
import plotly.express as px
import plotly
import json
import psycopg2
from flask import Flask, request, jsonify
from flask_cors import CORS
app = Flask(__name__)
CORS(app)  # Allow Cross-Origin requests (important for React frontend!)

conn = psycopg2.connect(
    host="localhost",
    database="employee_db",
    user="postgres",
    password="admin"
)
cur = conn.cursor()
@app.route('/api/chart')
def members():
    cur.execute("SELECT department, AVG(salary) AS avg_salary FROM employees GROUP BY department;")
    rows = cur.fetchall()
    df = pd.DataFrame(rows, columns=['Department', 'Salary'])
    fig = px.bar(df, x='Department', y='Salary', title='Average Salary by Department')

    fig.update_layout(width=400, height=300)  # <--- ADD THIS

    graphJSON = json.dumps(fig, cls=plotly.utils.PlotlyJSONEncoder)
    return graphJSON

@app.route('/api/male-female-chart')
def male_female_chart():
    cur.execute("SELECT department, absenteeism_rate_percentage FROM absenteeism_rate_view;")
    rows = cur.fetchall()
    df = pd.DataFrame(rows, columns=['Department','absenteeism_rate_percentage'])
    fig = px.bar(df, x="Department", y="absenteeism_rate_percentage", title="Absenteeism Rate by Department")
    graphJSON = json.dumps(fig, cls=plotly.utils.PlotlyJSONEncoder)
    return graphJSON


@app.route('/api/average_performance_view')
def average_performance_view():
    cur.execute("SELECT Age_Group, Seniority_Years FROM employee_distribution_view ORDER BY AGE_GROUP;")
    rows = cur.fetchall()
    df = pd.DataFrame(rows, columns=['Age_Group', 'Seniority_Years'])
    fig = px.line(df, x='Age_Group', y="Seniority_Years")
    graphJSON = json.dumps(fig, cls=plotly.utils.PlotlyJSONEncoder)
    return graphJSON


@app.route('/api/turnover_rate_view')
def Department_employee():
    cur.execute("SELECT department,turnover_rate_percentage FROM turnover_rate_view;")
    rows = cur.fetchall()
    df = pd.DataFrame(rows, columns=['department', 'turnover_rate_percentage'])
    fig = px.pie(df, names='department', values='turnover_rate_percentage', title='Deparment Employee turnover_rate_percentage')
    graphJSON = json.dumps(fig, cls=plotly.utils.PlotlyJSONEncoder)
    return graphJSON
@app.route('/api/employee-details', methods=['GET'])


def employee_details():
    cur.execute("SELECT id,name,department,dateofhire FROM employee_details;")
    rows = cur.fetchall()
    df = pd.DataFrame(rows, columns=['id', 'name', 'department', 'dateofhire'])
    return jsonify(df.to_dict(orient='records'))


@app.route('/api/count', methods=['GET'])
def employee_count():
    cur.execute("select * from  company_summary_view")
    rows = cur.fetchall()
    df = pd.DataFrame(rows, columns=['total_employees','average_age','average_performance','average_satisfaction'])
    return jsonify(df.to_dict(orient='records'))

@app.route('/api/female-male', methods=['GET'])
def female_male():
    cur.execute("SELECT male_count, female_count FROM gender_count_view;")
    rows = cur.fetchall()

    # Transform the data into a format suitable for a pie chart
    df = pd.DataFrame(rows, columns=['male_count', 'female_count'])
    pie_data = pd.DataFrame({
        'gender': ['Male', 'Female'],
        'count': [df['male_count'].sum(), df['female_count'].sum()]
    })

    # Create the pie chart
    fig = px.pie(pie_data, names='gender', values='count', title='')
    fig.update_layout(width=400, height=300)  # <--- ADD THIS

    graphJSON = json.dumps(fig, cls=plotly.utils.PlotlyJSONEncoder)

    return graphJSON
@app.route('/api/register', methods=['POST'])
def register_user():
    data = request.json
    data.get('name')
    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({'message': 'Email and Password are required'}), 400

    try:
        cur.execute("INSERT INTO users (email, password) VALUES (%s, %s)", (email, password))
        conn.commit()
        return jsonify({'message': 'User registered successfully!'}), 201
    except Exception as e:
        conn.rollback()
        print('Registration error:', str(e))  # 👈 Add this line to see real error in console
        return jsonify({'message': 'Registration failed', 'error': str(e)}), 500
if __name__ == '__main__':
    app.run(debug=True)
