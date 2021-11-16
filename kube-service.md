## Service

https://kubernetes.io/docs/concepts/services-networking/service/

https://kubernetes.io/pt-br/docs/tutorials/kubernetes-basics/expose/expose-intro/

## Como expor nosso um serviço? (Criar um service) 
```
kubectl export deployment <nome>
```

https://kubernetes.io/docs/concepts/services-networking/service/

- ClusterIP: Exposes the Service on a cluster-internal IP. Choosing this value makes the Service only reachable from within the cluster. This is the default ServiceType.

- NodePort: Exposes the Service on each Node's IP at a static port (the NodePort). A ClusterIP Service, to which the NodePort Service routes, is automatically created. You'll be able to contact the NodePort Service, from outside the cluster, by requesting <NodeIP>:<NodePort>.

- LoadBalancer: Exposes the Service externally using a cloud provider's load balancer. NodePort and ClusterIP Services, to which the external load balancer routes, are automatically created.

- ExternalName: Maps the Service to the contents of the externalName field (e.g. foo.bar.example.com), by returning a CNAME record with its value. No proxying of any kind is set up.

O service trabalha em cima do endpoint, quando chega uma requisição no service ele deve procurar para quem enviar aquela requisição com base nos endpoints criados


Exemplo:

```
kubectl create -f meu-primeiro.yaml

kubectl get pods -n giropops 
NAME    READY   STATUS              RESTARTS   AGE
nginx   0/1     ContainerCreating   0          27s



kubectl expose pod nginx --port=80 -n giropops
service/nginx exposed


kubectl get services -n giropops
NAME    TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
nginx   ClusterIP   10.105.62.75   <none>        80/TCP    41s


kubectl get endpoints -n giropops
NAME    ENDPOINTS        AGE
nginx   10.244.0.25:80   62s

Test
curl 10.244.0.25

Logs
kubectl logs -f nginx -n giropops
```

## Revisando detalhes do service
```
kubectl describe service nginx

Name:              nginx
Namespace:         default
Labels:            run=nginx
Annotations:       <none>
Selector:          run=nginx
Type:              ClusterIP
IP:                10.104.209.243
Port:              <unset>  80/TCP
TargetPort:        80/TCP
Endpoints:         10.46.0.0:80
Session Affinity:  None
Events:            <none>
```

**Importante**: Os endpoins são os endereços de cada replica do POD, quando quando olhamos o IP que está aparecendo no services será como um Load Balance que irá direcionar o trafego para cada ip de cada replica


