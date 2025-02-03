.PHONY: venv install deactivate clean

# Cria o ambiente virtual
venv:
	python3.10 -m venv venv
 
# Instruções para desativar o ambiente virtual
deactivate:
	@echo "Para desativar o ambiente virtual, execute: 'deactivate' no terminal"

version:
	which meltano
	meltano --version

	which cookiecutter
	cookiecutter --version

	which poetry
	poetry --version

	which ensurepath
	ensurepath --version


# Limpa o ambiente virtual removendo o diretório 'venv'
clean1:
	rm -rf venv
	@echo "Ambiente virtual removido com sucesso!"

create-directory:
	cookiecutter https://github.com/meltano/sdk --directory="cookiecutter/tap-template"

create-project-github:
	. /home/gnobisp/Documents/challenge-secret/venv/bin/activate && \
	meltano init metano-project && \
	cd metano-project && \
	meltano add extractor tap-github && \
	meltano init my-metano-project && \
	cd my-metano-project 

CONTAINER_NAME=challenge-secret_db_1

create-tap-postgres:
	. /home/gnobisp/Documents/challenge-secret/venv/bin/activate && \
	cd metano-project && \
	meltano add extractor tap-postgres && \
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
	meltano config tap-postgres set ssl_enable falsemeltano elt tap-postgres target-jsonl && \
	meltano config target-jsonl set destination_path /home/gnobisp/Documents/challenge-secret/output

create-tap-csv:
	. /home/gnobisp/Documents/challenge-secret/venv/bin/activate && \
	meltano init metano-project && \
	cd metano-project && \
	meltano add extractor tap-csv && \
	meltano config tap-csv set files "$(cat /home/gnobisp/Documents/challenge-secret/metano-project/.meltano/extractors/tap-csv/tap-csv-config.json | jq -c '.files')" && \
	meltano add loader target-jsonl && \
	meltano config target-jsonl set destination_path /home/gnobisp/Documents/challenge-secret/output && \
	meltano elt tap-csv target-jsonl


extrator-csv:
	. /home/gnobisp/Documents/challenge-secret/venv/bin/activate && \
	cd metano-project && \
	meltano add extractor tap-csv && \
	meltano init metano-project && \
	meltano elt tap-csv target-jsonl


change-directory:
	cd /home/gnobisp/Documents/challenge-secret/

discard-changes:
	git checkout -- .
	git reset --hard HEAD
	git clean -fd

csv-config:
	meltano config tap-csv set files "$(cat /home/gnobisp/Documents/challenge-secret/my-meltanoCSV-project/.meltano/extractors/tap-csv/venv/tap-csv-config.json | jq -c '.files')"

teste-conexao:
	python3 -m venv venv && \
	. /home/gnobisp/Documents/challenge-secret/venv/bin/activate && \
	pip install pandas && \
	pip install psycopg2-binary && \
	python3 testeConexao.py

reinicia-conexao:
	docker-compose down && \
	docker-compose up -d

# Makefile para configurar e executar o pipeline de ETL com tap-postgres e target-jsonl

# Variáveis de ambiente
VENV_PATH = /home/gnobisp/Documents/challenge-secret/venv/bin/activate
PROJECT_DIR = /home/gnobisp/Documents/challenge-secret/metano-project
OUTPUT_DIR = /home/gnobisp/Documents/challenge-secret/output


# Comando para ativar o ambiente virtual e executar comandos no projeto Meltano
ACTIVATE_VENV = . $(VENV_PATH) && cd $(PROJECT_DIR) &&



# Configuração do target-jsonl
create-target-jsonl-post:
	$(ACTIVATE_VENV) \
	meltano add loader target-jsonl && \
	meltano config target-jsonl set destination_path $(OUTPUT_DIR)

# Executar o pipeline de ETL
run-etl-post:
	$(ACTIVATE_VENV) \
	meltano elt tap-postgres target-jsonl


# Makefile para configurar e executar o pipeline de ETL com base no meltano.yml fornecido

# Variáveis de ambiente
VENV_PATH = /home/gnobisp/Documents/challenge-secret/venv/bin/activate
PROJECT_DIR = /home/gnobisp/Documents/challenge-secret/metano-project
CSV_PATH = /home/gnobisp/Documents/challenge-secret/data/order_details.csv
OUTPUT_DIR = /home/gnobisp/Documents/challenge-secret/output


# Comando para ativar o ambiente virtual e executar comandos no projeto Meltano
ACTIVATE_VENV = . $(VENV_PATH) && cd $(PROJECT_DIR) &&

# Instalar plugins e configurar o ambiente
setup1:
	. /home/gnobisp/Documents/challenge-secret/venv/bin/activate && \
	meltano init metano-project && \
	cd metano-project && \
	meltano add extractor tap-csv --variant meltanolabs && \
	meltano config tap-csv set files '[{"entity": "order_details", "path": "$(CSV_PATH)", "keys": ["order_id"], "format": "csv"}]' && \
	meltano add loader target-jsonl --variant andyh1203 && \
	meltano config target-jsonl set destination_path $(OUTPUT_DIR)




install-target-postgres:
	$(ACTIVATE) \
	meltano add loader target-postgres --variant meltanolabs && \
	meltano config target-postgres set host localhost && \
	meltano config target-postgres set port 5433 && \
	meltano config target-postgres set user processed_user && \
	meltano config target-postgres set password processed_password && \
	meltano config target-postgres set database northwind_processed && \
	meltano config target-postgres set schema public && \
	meltano config target-postgres set sslmode disable

ACTIVATE = . $(VENV_PATH) && cd $(PROJECT_DIR) &&
# Variáveis
VENV_PATH = /home/gnobisp/Documents/challenge-secret/venv/bin/activate
PROJECT_DIR = /home/gnobisp/Documents/challenge-secret/metano-project
CSV_PATH = /home/gnobisp/Documents/challenge-secret/data/order_details.csv
OUTPUT_DIR = /home/gnobisp/Documents/challenge-secret/data

# Comando base para ativação do ambiente virtual
ACTIVATE_VENV = . $(VENV_PATH) && cd $(PROJECT_DIR) &&

# Tarefa padrão: instala, configura e executa o pipeline
run: install setup create-tap-postgres-1 run-etl

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
create-tap-postgres-1:
	$(ACTIVATE_VENV) \
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
	meltano elt tap-csv target-parquet && \
	meltano elt tap-postgres target-parquet
	
run-nuvem:
	meltano elt tap-parquet target-postgres

# Limpa o ambiente (opcional)
clean:
	rm -rf venv
	rm -rf metano-project

.PHONY: run install setup create-tap-postgres-1 run-etl clean

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

airflow-start:##abrir novo terminal
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
	
