## Taints and Tolerations

Taints e tolerâncias trabalham juntos para garantir que pods não sejam alocados em nós inapropriados. Um ou mais taints são aplicados em um nó; isso define que o nó não deve aceitar nenhum pod que não tolera essas taints.

Taints e tolerâncias são um modo flexível de conduzir pods para fora dos nós ou expulsar pods que não deveriam estar sendo executados. Alguns casos de uso são

    
https://kubernetes.io/pt-br/docs/concepts/scheduling-eviction/taint-and-toleration/

Exemplo:

Você adiciona um taint a um nó utilizando kubectl taint. Por exemplo,


## NoSchedule 

O NoSchedule não permite adicionar mais pods no nó em caso de scale up


```bash
# Adicionar um taint
kubectl taint nodes node1 key1=value1:NoSchedule

# Remover o taint
kubectl taint node elliot-02 key1:NoSchedule-
```
No exemplo acima nenhum pode poderá se adicionado para aquele nó, porém se um nó tiver uma tolerância a ação NoSchedule ele isso significa que o pod conseguirá ser executado no nó.


O Taint nada mais é do que adicionar propriedades ao nó do cluster para impedir que os pods sejam alocados em nós inapropriados.

Por exemplo, todo nó master do cluster é marcado para não receber pods que não sejam de gerenciamento do cluster.

O nó master está marcado com o taint NoSchedule, assim o scheduler do Kubernetes não aloca pods no nó master, e procura outros nós no cluster sem essa marca.

## NoExecute 

O NoExecute remove os pods que não tem tolerância

```bash
# Adicionar um taint
kubectl taint node elliot-02 key1=value1:NoExecute

# Remover o taint
kubectl taint node elliot-02 key1:NoExecute-
```