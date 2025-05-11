import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
import joblib
import psycopg2

# Connect to DB
conn = psycopg2.connect(
    host="localhost",
    database="employee_db",
    user="postgres",
    password="admin"
)

query = """
SELECT 
    DATE_PART('year', AGE(CURRENT_DATE, DOB)) AS Age,
    Salary,
    Department,
    CitizenDesc,
    Sex,
    Turnover
FROM 
    employees
WHERE 
    DOB IS NOT NULL AND Salary IS NOT NULL;

"""
df = pd.read_sql(query, conn)

# Encode categorical
for col in ['Department', 'CitizenDesc', 'Sex']:
    df[col] = LabelEncoder().fit_transform(df[col])

X = df[['Age', 'Salary', 'Department', 'CitizenDesc', 'Sex']]
y = df['Turnover']

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
model = LogisticRegression()
model.fit(X_train, y_train)

# Save model
joblib.dump(model, 'model/turnover_predictor.pkl')
print("✅ Model trained and saved at model/turnover_predictor.pkl")
