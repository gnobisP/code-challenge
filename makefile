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
	. /home/gnobisp/Documents/challenge-secret/venv/bin/activate && \
	pip install pandas && \
	pip install psycopg2-binary && \
	python3 testeConexao.py

reinicia-conexao:
	docker-compose down && \
	docker-compose up -d

# Comando para ativar o ambiente virtual e executar comandos no projeto Meltano
ACTIVATE_VENV_MELTANO := . $(VENV_PATH_MELTANO) && cd $(PROJECT_DIR) &&
# Comando para ativar o ambiente virtual e executar comandos no projeto Meltano
ACTIVATE_VENV_AIRFLOW := . $(VENV_PATH_AIRFLOW) && cd $(PROJECT_DIR) &&
# Define o diretório do projeto como o diretório atual
PROJECT_DIR := $(shell pwd)
# Define o caminho para o ambiente virtual (assumindo que ele está na pasta 'venv' dentro do projeto)
VENV_PATH_AIRFLOW := $(PROJECT_DIR)/venv_airflow/bin/activate
# Define o caminho para o ambiente virtual (assumindo que ele está na pasta 'venv' dentro do projeto)
VENV_PATH_MELTANO := $(PROJECT_DIR)/venv_meltano/bin/activate
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
	meltano config target-jsonl set destination_path $(OUTPUT_DIR) && \
	meltano config target-csv set destination_path $(OUTPUT_DIR)  
	

# Configuração do tap-postgres (mantido igual)
create-tap-postgres:
	$(ACTIVATE_VENV_MELTANO) \
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
	$(ACTIVATE_VENV_MELTANO) \
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

parquet-config:
	echo '[ \
		{"entity": "order_details", "path": "$(DATA_PATH)/csv/$(DATE)/order_details/order_details-*.parquet", "keys": ["order_id"]}, \
		{"entity": "public_categories", "path": "$(DATA_PATH)/postgres/$(DATE)/public-categories/public-categories-*.parquet", "keys": ["category_id"]}, \
		{"entity": "public-customers", "path": "$(DATA_PATH)/postgres/$(DATE)/public-customers/public-customers-*.parquet", "keys": ["customer_id"]}, \
		{"entity": "public-employee_territories", "path": "$(DATA_PATH)/postgres/$(DATE)/public-employee_territories/public-employee_territories-*.parquet", "keys": ["employee_id", "territory_id"]}, \
		{"entity": "public-orders", "path": "$(DATA_PATH)/postgres/$(DATE)/public-orders/public-orders-*.parquet", "keys": ["order_id"]}, \
		{"entity": "public-products", "path": "$(DATA_PATH)/postgres/$(DATE)/public-products/public-products-*.parquet", "keys": ["product_id"]}, \
		{"entity": "public-region", "path": "$(DATA_PATH)/postgres/$(DATE)/public-region/public-region-*.parquet", "keys": ["region_id"]}, \
		{"entity": "public-shippers", "path": "$(DATA_PATH)/postgres/$(DATE)/public-shippers/public-shippers-*.parquet", "keys": ["shipper_id"]}, \
		{"entity": "public-suppliers", "path": "$(DATA_PATH)/postgres/$(DATE)/public-suppliers/public-suppliers-*.parquet", "keys": ["supplier_id"]}, \
		{"entity": "public-territories", "path": "$(DATA_PATH)/postgres/$(DATE)/public-territories/public-territories-*.parquet", "keys": ["territory_id"]}, \
		{"entity": "public-us_states", "path": "$(DATA_PATH)/postgres/$(DATE)/public-us_states/public-us_states-*.parquet", "keys": ["state_id"]} \
	]' > /tmp/parquet_config.json && \
	meltano config tap-parquet set files "$$(cat /tmp/parquet_config.json)"

