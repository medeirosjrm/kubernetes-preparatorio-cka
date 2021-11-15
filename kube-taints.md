## Taints and Tolerations

Taints e tolerâncias trabalham juntos para garantir que pods não sejam alocados em nós inapropriados. Um ou mais taints são aplicados em um nó; isso define que o nó não deve aceitar nenhum pod que não tolera essas taints.

Taints e tolerâncias são um modo flexível de conduzir pods para fora dos nós ou expulsar pods que não deveriam estar sendo executados. Alguns casos de uso são

    
https://kubernetes.io/pt-br/docs/concepts/scheduling-eviction/taint-and-toleration/

Exemplo:

Você adiciona um taint a um nó utilizando kubectl taint. Por exemplo,

```
kubectl taint nodes node1 key1=value1:NoSchedule
```
No exemplo acima nenhum pode poderá se adicionado para aquele nó, porém se um nó tiver uma tolerância a ação NoSchedule ele isso significa que o pod conseguirá ser executado no nó.