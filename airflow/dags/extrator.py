from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from datetime import datetime

def process_data_function():
    print("Processando dados...")

default_args = {
    "owner": "northwind_team",
    "start_date": datetime(2024, 1, 1),
    "retries": 2
}

with DAG(
    "northwind_data_pipeline",
    default_args=default_args,
    schedule="@daily",
    catchup=False,  
    description="Pipeline para extrair dados do Northwind e salvar em Parquet",
    tags=["northwind", "elt"],
) as dag:

    extract_csv = BashOperator( 
        task_id="extract_csv",
        bash_command="script/extratorPOSTGRE.sh",
    )

    extract_postgres = BashOperator( 
        task_id="extract_postgres",
        bash_command="script/extratorCSV.sh",
    )

    process_data = PythonOperator(
        task_id="process_data",
        python_callable=process_data_function,
    )

    bash_task = BashOperator(
        task_id="bash_task",
        bash_command="echo \"here is the message: '$message'\"",
        env={"message": '{{ dag_run.conf["message"] if dag_run.conf else "" }}'},
        )

    # Executar extrações em paralelo
    [extract_csv, extract_postgres, bash_task] >> process_data
