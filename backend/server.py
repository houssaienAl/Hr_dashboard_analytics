from flask import Flask, jsonify
import pandas as pd
import plotly.express as px
import plotly
import json
import psycopg2
app = Flask(__name__)
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
    # Query the employee_details view
    cur.execute("SELECT * FROM employee_details;")
    rows = cur.fetchall()

    # Convert the query result to a Pandas DataFrame
    df = pd.DataFrame(rows, columns=['Name', 'Department', 'ID', 'DateOfHire'])

    # Convert the DataFrame to a JSON response
    return jsonify(df.to_dict(orient='records'))
   
if __name__ == '__main__':
    app.run(debug=True)
