
# Defina o caminho do ambiente virtual
VENV_PATH="/home/gnobisp/Documents/floder1/code-challenge/venv/bin/activate"
PROJECT_PATH="/home/gnobisp/Documents/floder1/code-challenge/metano-project"
DATA_PATH="/home/gnobisp/Documents/floder1/code-challenge/data"

# Ativa o ambiente virtual
source $VENV_PATH

# Obtém a data atual para organizar as pastas
CURRENT_DATE=$(date +%Y-%m-%d)

# Função para obter caminho de saída
get_output_path() {
    local source_type=$1  # "csv" ou "postgres"
    local table_name=$2  # Nome da tabela ou "csv" para arquivos CSV
    echo "$DATA_PATH/$source_type/$table_name/$CURRENT_DATE/"
}

# Função para extrair CSV
extract_csv() {
    set -e  # Faz com que qualquer erro pare a execução
    cd $PROJECT_PATH
    local output_dir=$(get_output_path "csv" "")
    mkdir -p "$output_dir"
    export TARGET_PARQUET_DESTINATION_PATH="$output_dir"
    meltano run tap-csv target-parquet
}

# Função para extrair dados do Postgres
extract_postgres() {
    set -e
    cd $PROJECT_PATH
    local output_dir=$(get_output_path "postgres" "$table")
    mkdir -p "$output_dir"
    export TARGET_PARQUET_DESTINATION_PATH="$output_dir"
    meltano run tap-postgres target-parquet
    
}

# Chama as funções
extract_csv
extract_postgres
