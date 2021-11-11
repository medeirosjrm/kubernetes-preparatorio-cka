if [ -z $1 ]; then
  echo "Informe a versao $1"
  exit 1
fi

helm install contas-php ./ -f ./values.yaml --set versao=$1