import pandas as pd
import psycopg2

conn = psycopg2.connect(
    dbname="northwind",
    user="northwind_user",
    password="thewindisblowing",
    host="localhost",
    port="5432"
)

query = "SELECT * FROM customers;"
df = pd.read_sql(query, conn)
df.to_csv("customers.csv", index=False)  # Exporta para CSV
conn.close()
