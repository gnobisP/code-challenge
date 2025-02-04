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
    description="Pipeline para extrair dados do Northwind e salvar em Parquet",
    tags=["northwind", "elt"],
) as dag:

    # Tarefa para extrair dados do CSV (um arquivo por dia)
    extract_csv = BashOperator(
        task_id="extract_csv",
        bash_command="""
            cd /home/gnobisp/Documents/floder1/Code-challenge/metano && \
            meltano run tap-csv target-parquet \
                --config='files.0.entity=order_details' \
                --config='files.0.path=/caminho/absoluto/Code-challenge/data/order_details.csv' \
                --config='target-parquet.destination_path=/home/gnobisp/Documents/floder1/Code-challenge/data/csv/{{ ds }}/'
        """,
    )

    # Tarefa para extrair dados do PostgreSQL (um arquivo por tabela/dia)
    extract_postgres = BashOperator(
        task_id="extract_postgres",
        bash_command="""
            cd /home/gnobisp/Documents/floder1/Code-challenge/metano && \
            meltano run tap-postgres target-parquet \
                --config='filter_schemas=public' \
                --config='target-parquet.destination_path=/home/gnobisp/Documents/floder1/Code-challenge/data/postgres/{{ stream }}/{{ ds }}/'
        """,
    )

    process_data = PythonOperator(
        task_id="process_data",
        python_callable=process_data,
    )

    # Executar extrações em paralelo
    [extract_csv, extract_postgres] >> process_data
