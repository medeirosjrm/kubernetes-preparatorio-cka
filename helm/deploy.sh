if [ -z $1 ]; then
  echo "Informe a ambiente $1"
  exit 1
fi

if [ -z $2 ]; then
  echo "Informe o versao $2"
  exit 1
fi

DEBUG='--debug'
if [ -z $3 ]; then
  DEBUG=''
fi

helm upgrade $DEBUG  contas-php ./ -f ./values.yaml --set ambiente=$1 --set versao=$2