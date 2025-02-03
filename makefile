.PHONY: venv install deactivate clean

# Cria o ambiente virtual
venv:
	python3.10 -m venv venv
 
discard-changes:
	git checkout -- .
	git reset --hard HEAD
	git clean -fd

teste-conexao:
	python3 -m venv venv && \
	. /home/gnobisp/Documents/challenge-secret/venv/bin/activate && \
	pip install pandas && \
	pip install psycopg2-binary && \
	python3 testeConexao.py

reinicia-conexao:
	docker-compose down && \
	docker-compose up -d

# Comando para ativar o ambiente virtual e executar comandos no projeto Meltano
ACTIVATE_VENV = . $(VENV_PATH) && cd $(PROJECT_DIR) &&
# Define o diretório do projeto como o diretório atual
PROJECT_DIR := $(shell pwd)
# Define o caminho para o ambiente virtual (assumindo que ele está na pasta 'venv' dentro do projeto)
VENV_PATH := $(PROJECT_DIR)/venv/bin/activate
# Define o caminho para o arquivo CSV (assumindo que ele está na pasta 'data' dentro do projeto)
CSV_PATH := $(PROJECT_DIR)/data/order_details.csv
# Define o diretório de saída (assumindo que ele está na pasta 'data' dentro do projeto)
OUTPUT_DIR := $(PROJECT_DIR)/data

# Instala os pacotes no ambiente virtual
install: venv
	venv/bin/pip install --upgrade pip
	venv/bin/pip install meltano

# Configuração inicial do projeto Meltano (substitua target-jsonl por target-parquet)
setup:
	. $(VENV_PATH) && \
	meltano init metano-project && \
	cd metano-project && \
	meltano add extractor tap-parquet && \
	meltano add extractor tap-csv --variant meltanolabs && \
	meltano config tap-csv set files '[{"entity": "order_details", "path": "$(CSV_PATH)", "keys": ["order_id"], "format": "csv"}]' && \
	meltano add loader target-parquet && \
	meltano config target-parquet set destination_path $(OUTPUT_DIR) 

# Configuração do tap-postgres (mantido igual)
create-tap-postgres:
	$(ACTIVATE_VENV) \
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

# Executar o pipeline de ETL para salvar em Parquet
run-etl:
	$(ACTIVATE_VENV) \
	cd metano-project && \
	meltano elt tap-csv target-parquet && \
	meltano elt tap-postgres target-parquet
	
run-nuvem:
	meltano elt tap-parquet target-postgres

# Limpa o ambiente (opcional)
clean:
	rm -rf venv
	rm -rf metano-project

# Tarefa padrão: instala, configura e executa o pipeline
run: install setup create-tap-postgres run-etl

airflow-install:
	. $(VENV_PATH) && \
	pip install "apache-airflow[celery]==2.10.4" --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.10.4/constraints-3.12.txt" && \
	export AIRFLOW_HOME=/home/gnobisp/Documents/challenge-secret/airflowTutorial && \
	airflow db init 

airflow-config-user:
	. $(VENV_PATH) && \
	cd airflow && \
	airflow users create --username admin --firstname admin --lastname admin --role Admin --email admin@admin.com && \
	123456 && \
	123456

airflow-start:#abrir novo terminal
	. $(VENV_PATH) && \
	export AIRFLOW_HOME=/home/gnobisp/Documents/challenge-secret/airflowTutorial && \
	airflow scheduler && \
	airflow webserver -p 8081
	

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
	
