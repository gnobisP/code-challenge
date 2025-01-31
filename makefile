.PHONY: venv install deactivate clean

# Cria o ambiente virtual
venv:
	python3 -m venv venv
	

# Instala os pacotes no ambiente virtual
install: venv
	venv/bin/pip install --upgrade pip
	venv/bin/pip install meltano cookiecutter poetry ensurepath
 
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
clean:
	rm -rf venv
	@echo "Ambiente virtual removido com sucesso!"

create-directory:
	cookiecutter https://github.com/meltano/sdk --directory="cookiecutter/tap-template"

create-project-github:
	. /media/gnobisp/Novo\ volume/Gustavo/SistemadeDados/code-challenge/venv/bin/activate && \
	meltano init metano-project && \
	cd metano-project && \
	meltano add extractor tap-github && \
	meltano init my-meltano-project && \
	cd my-meltano-project 

create-tap-postgres:
	. /media/gnobisp/Novo\ volume/Gustavo/SistemadeDados/code-challenge/venv/bin/activate && \
	meltano init metano-project && \
	cd metano-project && \
	meltano add extractor tap-postgres && \
	meltano config tap-postgres set host localhost && \
	meltano config tap-postgres set port 5432 && \
	meltano config tap-postgres set dbname northwind && \
	meltano config tap-postgres set user northwind_user && \
	meltano config tap-postgres set password thewindisblowing && \
	meltano config tap-postgres set database northwind && \
	meltano add loader target-jsonl && \
	meltano config target-jsonl set destination_path /media/gnobisp/Novo\ volume/Gustavo/SistemadeDados/code-challenge/output/ && \
	meltano elt tap-postgres target-jsonl

create-tap-csv:
	. /media/gnobisp/Novo\ volume/Gustavo/SistemadeDados/code-challenge/venv/bin/activate && \
	meltano init metano-project && \
	cd metano-project && \
	meltano add extractor tap-csv && \
	meltano config tap-csv set files "$(cat /media/gnobisp/Novo\ volume/Gustavo/SistemadeDados/code-challenge/metano-project/.meltano/extractors/tap-csv/tap-csv-config.json | jq -c '.files')" && \
	meltano add loader target-jsonl && \
	meltano config target-jsonl set destination_path /media/gnobisp/Novo\ volume/Gustavo/SistemadeDados/code-challenge/output/ && \
	meltano elt tap-csv target-jsonl


extrator-csv:
	. /media/gnobisp/Novo\ volume/Gustavo/SistemadeDados/code-challenge/venv/bin/activate && \
	cd metano-project && \
	meltano add extractor tap-csv && \
	meltano init metano-project && \
	meltano elt tap-csv target-jsonl


change-directory:
	cd /media/gnobisp/Novo\ volume/Gustavo/SistemadeDados/code-challenge

discard-changes:
	git checkout -- .
	git reset --hard HEAD
    git clean -fd

csv-config:
	meltano config tap-csv set files "$(cat /media/gnobisp/Novo\ volume/Gustavo/SistemadeDados/code-challenge/my-meltanoCSV-project/.meltano/extractors/tap-csv/venv/tap-csv-config.json | jq -c '.files')"