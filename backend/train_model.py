# train_model.py
import pandas as pd
import psycopg2
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report
import joblib

# PostgreSQL connection
conn = psycopg2.connect(
    dbname="employee_db",
    user="postgres",
    password="admin",
    host="localhost",
    port="5432"
)

# Load employee data
df = pd.read_sql("SELECT * FROM employees WHERE termd IN (0, 1)", conn)

# Preprocess
df = df.drop(columns=[
    'id', 'employee_name', 'empid', 'dob',
    'dateofhire', 'dateoftermination', 'lastperformancereview_date'
])
df = df.fillna(0)
df = pd.get_dummies(df)

X = df.drop("turnover", axis=1)
y = df["turnover"]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# Print metrics
print(classification_report(y_test, model.predict(X_test)))

# Save model
joblib.dump(model, "turnover_predictor.pkl")
