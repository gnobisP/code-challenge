from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from datetime import datetime

def process_data():
    print("Processando dados...")

default_args = {
    "owner": "northwind_team",
    "start_date": datetime(2024, 1, 1),
    "retries": 2
}

with DAG(
    "northwind_data_pipeline",
    default_args=default_args,
    schedule_interval="@daily",
    description="Pipeline para extrair e processar dados do Northwind",
    tags=["northwind", "elt"],
) as dag:

    extract_csv = BashOperator(
        task_id="extract_csv",
        bash_command="meltano run tap-csv target-parquet "
                     "--config='target-parquet.destination_path=/data/csv/{{ ds }}/'",
    )

    extract_postgres = BashOperator(
        task_id="extract_postgres",
        bash_command="meltano run tap-postgres target-parquet "
                     "--config='target-parquet.destination_path=/data/postgres/public/{{ ds }}/'",
    )

    process_data = PythonOperator(
        task_id="process_data",
        python_callable=process_data,
    )

    # Remova a dependência entre extract_csv e extract_postgres
    # Agora, as duas tarefas serão executadas em paralelo
    [extract_csv, extract_postgres] >> process_data