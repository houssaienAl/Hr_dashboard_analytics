from flask import Flask, jsonify
import pandas as pd
import plotly.express as px
import plotly
import json
import psycopg2
from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import numpy as np
from sklearn.preprocessing import LabelEncoder

app = Flask(__name__)
CORS(app)  # Allow Cross-Origin requests (important for React frontend!)
model = joblib.load('turnover_predictor.pkl')
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
    fig = px.bar(df, x='Department', y='Salary', title='')

    fig.update_layout(width=400, height=300)  # <--- ADD THIS

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
    cur.execute("SELECT id,Employee_name,department,dateofhire FROM employees order by dateofhire DESC;")
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
    name = data.get('name')
    email = data.get('email')
    password = data.get('password')

    if not email or not password or not name:
        return jsonify({'message': 'Name, Email, and Password are required'}), 400

    try:
        # Check if the email already exists
        cur.execute("SELECT COUNT(*) FROM users WHERE email = %s", (email,))
        email_exists = cur.fetchone()[0]

        if email_exists > 0:
            return jsonify({'message': 'Email is already in use'}), 400

        # Insert the new user
        cur.execute("INSERT INTO users (name, email, password) VALUES (%s, %s, %s)", (name, email, password))
        conn.commit()
        return jsonify({'message': 'User registered successfully!'}), 201
    except Exception as e:
        conn.rollback()
        print('Registration error:', str(e))  # Debugging: Log the error
        return jsonify({'message': 'Registration failed', 'error': str(e)}), 500

@app.route('/api/add-employee', methods=['POST'])
def add_employee():
    data = request.json
    name = data.get('Name')
    department = data.get('Department')
    salary = data.get('Salary')
    citizendesc = data.get('citizendesc')
    turnover = data.get('turnover', '0')  # Default to '0' if not provided
    gender = data.get('gender', 'M')  # Default to 'Male' if not provided

    if not name or not department or not salary or not citizendesc:
        return jsonify({'message': 'All fields are required'}), 400

    try:
        cur.execute(
            """
            INSERT INTO employees (Employee_Name, Department, Salary, CitizenDesc, Turnover, Sex, dateofhire)
            VALUES (%s, %s, %s, %s, %s, %s, CURRENT_DATE)
            """,
            (name, department, salary, citizendesc, turnover, gender)
        )
        conn.commit()
        return jsonify({'message': 'Employee added successfully!'}), 201
    except Exception as e:
        conn.rollback()
        print('Error adding employee:', str(e))
        return jsonify({'message': 'Failed to add employee', 'error': str(e)}), 500

@app.route('/api/login', methods=['POST'])
def login_user():
    data = request.json
    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({'message': 'Email and Password are required'}), 400

    try:
        # Check if the user exists and the password matches
        cur.execute("SELECT id, name FROM users WHERE email = %s AND password = %s", (email, password))
        user = cur.fetchone()

        if user:
            return jsonify({'message': 'Login successful!', 'user': {'id': user[0], 'name': user[1]}}), 200
        else:
            return jsonify({'message': 'Invalid email or password'}), 401
    except Exception as e:
        print('Login error:', str(e))  # Debugging: Log the error
        return jsonify({'message': 'Login failed', 'error': str(e)}), 500

@app.route('/api/delete-employee/<int:employee_id>', methods=['DELETE'])
def delete_employee(employee_id):
    try:
        # Check if the employee exists
        cur.execute("SELECT id FROM employees WHERE id = %s", (employee_id,))
        employee = cur.fetchone()

        if not employee:
            return jsonify({'message': 'Employee not found'}), 404

        # Delete the employee
        cur.execute("DELETE FROM employees WHERE id = %s", (employee_id,))
        conn.commit()
        return jsonify({'message': 'Employee deleted successfully!'}), 200
    except Exception as e:
        conn.rollback()
        print('Error deleting employee:', str(e))  # Debugging: Log the error
        return jsonify({'message': 'Failed to delete employee', 'error': str(e)}), 500
    @app.route('/api/predict-turnover', methods=['GET'])
def predict_turnover():
    cur.execute("SELECT id, Age, Salary, Department, CitizenDesc, Sex FROM employees WHERE Age IS NOT NULL AND Salary IS NOT NULL;")
    rows = cur.fetchall()
    df = pd.DataFrame(rows, columns=['id', 'Age', 'Salary', 'Department', 'CitizenDesc', 'Sex'])

    for col in ['Department', 'CitizenDesc', 'Sex']:
        df[col] = LabelEncoder().fit_transform(df[col])

    features = df[['Age', 'Salary', 'Department', 'CitizenDesc', 'Sex']]
    predictions = model.predict(features)
    df['prediction'] = predictions

    return jsonify(df.to_dict(orient='records'))

if __name__ == '__main__':
    app.run(debug=True)
