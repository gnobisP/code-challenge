# Comando para ativar o ambiente virtual e executar comandos no projeto Meltano
ACTIVATE_VENV = . $(VENV_PATH) && cd $(PROJECT_DIR) &&

# Define o diretório do projeto como o diretório atual
PROJECT_DIR := $(shell pwd)

# Define o caminho para o ambiente virtual (assumindo que ele está na pasta 'venv' dentro do projeto)
VENV_PATH := $(PROJECT_DIR)/venv/bin/activate

# define airflow dir
AIRFLOW_PATH := $(PROJECT_DIR)


 
airflow-install:
	python3.10 -m venv venv && \
	. $(ACTIVATE_VENV ) && \
	pip install "apache-airflow[celery]==2.10.4" --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.10.4/constraints-3.12.txt" && \
	export AIRFLOW_HOME=$(AIRFLOW_PATH) && \
	airflow db init 

airflow-config-user:
	. $(ACTIVATE_VENV ) && \
	cd $(AIRFLOW_PATH) && \
	airflow users create --username admin0 --firstname admin0 --lastname admin --role Admin --email admin0@admin.com --password 123456

airflow-start0:#abrir novo terminal
	. $(VENV_PATH) && \
	export AIRFLOW_HOME=$(AIRFLOW_PATH) && \
	airflow webserver -p 8088

airflow-start1:
	. $(VENV_PATH) && \
	export AIRFLOW_HOME=$(AIRFLOW_PATH) && \
	airflow scheduler

#scheduler e airflow
airflow-process:
	lsof -i :8793 && \
	kill -9 PID 

	
airflow: airflow-install airflow-config-user airflow-start