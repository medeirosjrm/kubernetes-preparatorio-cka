# Caso queira criar um secrets manualmente sem o deploy pelo helm
kubectl create secret -n ns-da-aplicacao generic secrets-name --from-file=database.config