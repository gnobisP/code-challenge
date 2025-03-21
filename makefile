.PHONY: venv install deactivate clean

# Cria o ambiente virtual
venv-airflow:
	python3.10 -m venv venv_airflow
 
venv-meltano:
	python3.10 -m venv venv_meltano

discard-changes:
	git checkout -- .
	git reset --hard HEAD
	git clean -fd

teste-conexao:
	python3 -m venv venv && \
	$(ACTIVATE_VENV_TESTE_CONEXAO) \
	pip install pandas && \
	pip install psycopg2-binary && \
	python3 testeConexao.py

reinicia-conexao:
	docker-compose down && \
	docker-compose up -d

# Comando para ativar o ambiente virtual e executar comandos no projeto Meltano
ACTIVATE_VENV_MELTANO := . $(VENV_PATH_MELTANO)
# Comando para ativar o ambiente virtual e executar comandos no projeto Meltano
ACTIVATE_VENV_AIRFLOW := . $(VENV_PATH_AIRFLOW) && cd $(PROJECT_DIR) &&
# Comando para ativar o ambiente virtual e executar comandos no projeto Meltano
ACTIVATE_VENV_TESTE_CONEXAO := . $(VENV_PATH_TESTE) 
# Define o diretório do projeto como o diretório atual
PROJECT_DIR := $(shell pwd)
# Define o caminho para o ambiente virtual (assumindo que ele está na pasta 'venv' dentro do projeto)
VENV_PATH_AIRFLOW := $(PROJECT_DIR)/venv_airflow/bin/activate
# Define o caminho para o ambiente virtual (assumindo que ele está na pasta 'venv' dentro do projeto)
VENV_PATH_MELTANO := $(PROJECT_DIR)/venv_meltano/bin/activate
# Define o caminho para o ambiente virtual (assumindo que ele está na pasta 'venv' dentro do projeto)
VENV_PATH_TESTE := $(PROJECT_DIR)/venv/bin/activate
# Define o caminho para o arquivo CSV (assumindo que ele está na pasta 'data' dentro do projeto)
CSV_PATH := $(PROJECT_DIR)/data/order_details.csv
# Define o diretório de saída (assumindo que ele está na pasta 'data' dentro do projeto)
OUTPUT_DIR := $(PROJECT_DIR)/data
# define airflow dir
AIRFLOW_PATH := $(PROJECT_DIR)/airflow

# Instala os pacotes no ambiente virtual
install: venv-meltano
	venv_meltano/bin/pip3 install --upgrade pip
	venv_meltano/bin/pip3 install meltano

# Configuração inicial do projeto Meltano
setup:
	. $(VENV_PATH_MELTANO) && \
	meltano init metano-project && \
	cd metano-project && \
	meltano add extractor tap-parquet && \
	meltano add extractor tap-csv --variant meltanolabs && \
	meltano config tap-csv set files '[{"entity": "order_details", "path": "$(CSV_PATH)", "keys": ["order_id"], "format": "csv"}]' && \
	meltano add loader target-parquet && \
	meltano add loader target-jsonl && \
	meltano config target-parquet set destination_path $(OUTPUT_DIR)  && \
	meltano config target-jsonl set destination_path $(OUTPUT_DIR)
	

# Configuração do tap-postgres (mantido igual)
create-tap-postgres:
	. $(VENV_PATH_MELTANO) && \
	cd metano-project && \
	meltano add extractor tap-postgres --variant meltanolabs && \
	meltano config tap-postgres set host localhost && \
	meltano config tap-postgres set port 5432 && \
	meltano config tap-postgres set dbname northwind && \
	meltano config tap-postgres set user northwind_user && \
	meltano config tap-postgres set password thewindisblowing && \
	meltano config tap-postgres set database northwind && \
	meltano config tap-postgres set default_replication_method FULL_TABLE && \
	meltano config tap-postgres set filter_schemas '["public"]' && \
	meltano config tap-postgres set max_record_count 10000 && \
	meltano config tap-postgres set dates_as_string false && \
	meltano config tap-postgres set json_as_object false && \
	meltano config tap-postgres set ssl_enable false

# Configuração do tap-postgres (mantido igual)
create-tap-parquet:
	. $(VENV_PATH_MELTANO) && \
	cd metano-project && \
	meltano add extractor tap-parquet
	

# Configuração do tap-postgres (mantido igual)
create-tap-csv:
	. $(VENV_PATH_MELTANO) && \
	cd metano-project && \
	meltano add extractor tap-csv --variant meltanolabs

# Configuração do tap-postgres (mantido igual)
create-load-parquet:
	. $(VENV_PATH_MELTANO) && \
	cd metano-project && \
	meltano add loader target-parquet && \
	meltano config target-parquet set destination_path $(OUTPUT_DIR) 

# Configuração do tap-postgres (mantido igual)
create-load-jsonl:
	. $(VENV_PATH_MELTANO) && \
	cd metano-project && \
	meltano add loader target-jsonl && \
	meltano config target-jsonl set destination_path $(OUTPUT_DIR)

# Configuração do tap-postgres (mantido igual)
create-load-csv:
	. $(VENV_PATH_MELTANO) && \
	cd metano-project && \
	meltano add loader target-csv && \
	meltano config target-csv set destination_path $(OUTPUT_DIR)

	
# Executar o pipeline de ETL para salvar em Parquet
run-etl:
	. $(VENV_PATH_MELTANO) && \
	cd metano-project && \
	meltano elt tap-csv target-csv-csv && \
	meltano elt tap-postgres target-postgres-csv
	

run-nuvem:
	meltano elt tap-parquet target-postgres

# Limpa o ambiente (opcional)
clean:
	rm -rf venv
	rm -rf metano-project
	


install_meltano: venv-meltano
	venv_meltano/bin/pip3 install --upgrade pip
	venv_meltano/bin/pip3 install meltano
	. $(VENV_PATH_MELTANO) && \
	cd metano-project

configura_meltano: create-tap-parquet create-tap-csv create-tap-postgres create-load-parquet create-load-jsonl

setup_meltano: install_meltano configura_meltano


# Tarefa padrão: instala, configura e executa o pipeline
run: install setup create-tap-postgres run-etl 

install_metano: install setup create-tap-postgres

install_airflow: airflow-install airflow-config-user airflow-start

 
airflow-install: 
	pip install "apache-airflow[celery]==2.10.4" --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.10.4/constraints-3.12.txt" && \
	export AIRFLOW_HOME=$(AIRFLOW_PATH) && \
	mkdir -p ./dags ./logs ./plugins ./config && /
	airflow db migrate

airflow-config-user:
	export AIRFLOW_HOME=$(AIRFLOW_PATH) && \
	airflow db migrate && \
	cd $(AIRFLOW_PATH) && \
	airflow users create --username admin --firstname admin --lastname admin --role Admin --email admin@admin.com --password 123456
#export AIRFLOW_HOME=/home/gnobisp/Documents/folder1/code-challenge/airflow
airflow-start0:#abrir novo terminal
	export AIRFLOW_HOME=$(AIRFLOW_PATH) && \
	airflow webserver -p 8089

airflow-start1:
	export AIRFLOW_HOME=$(AIRFLOW_PATH) && \
	airflow scheduler
	
airflow: airflow-install airflow-config-user airflow-start

#fazer alterações do video 13:57
airflow-docker:
	mkdir docker-compose && /
	cd docker-compose && /
	curl -LfO 'https://airflow.apache.org/docs/apache-airflow/2.10.4/docker-compose.yaml' && /
	mkdir -p ./dags ./logs ./plugins ./config && /
	echo -e "AIRFLOW_UID=$(id -u)" > .env  && /
	docker-compose up airflow-init  && /
	docker-compose up -d
	
airflow-process:
	lsof -i :8793 && \
	kill -9 PID 
#utilizar SUDO
