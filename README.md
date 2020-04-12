# k8s-practice

## Precondition
- I use Vagrant and ViratulBox.
    - if you create kubernetes cluster according to this document, you need to install Vagrant and VirtualBox beforehand.
- I chose Ubuntu for the Kubernetes Cluster OS.
- I chose flannel for Layer 3 network fabric designed for Kubernetes.
- I create three Kubernetes Cluster node(master node, worker node1, worker node2)
- My kubernetes network diagram is as follows.



## First, create master node cluster
$ git clone "this repository"
$ cd k8s-practice/master && vagrant up

```
    default: Your Kubernetes control-plane has initialized successfully!
    default:
    default: To start using your cluster, you need to run the following as a regular user:
    default:
    default:   mkdir -p $HOME/.kube
    default:   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    default:   sudo chown $(id -u):$(id -g) $HOME/.kube/config
    default:
    default: You should now deploy a pod network to the cluster.
    default: Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
    default:   https://kubernetes.io/docs/concepts/cluster-administration/addons/
    default: Then you can join any number of worker nodes by running the following on each as root:
    default: kubeadm join 192.168.100.10:6443 --token tftn6v.l2lk120fptpvn2l1 \
    default:     --discovery-token-ca-cert-hash sha256:4ca2xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

- setting kubectl environment (VM)

```
## login to virtual machine(master node)
$ vagrant ssh

## setting environment
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

- setting kubectl environment (local machine. not VM)

```
$ cd k8s-practice/master
$ vagrant.exe ssh-config >> ssh-config
$ scp -F ssh-config vagrant@default:~/.kube/config .
$ mkdir -p $HOME/.kube
$ sudo cp -i ./config $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
$ kubectl get node
NAME     STATUS     ROLES    AGE   VERSION
master   NotReady   master   24m   v1.18.1
```

- setting kubernetes network(flannel)

```
$ curl -O https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
$ sed -i 's/kube-subnet-mgr/kube-subnet-mgr\n        \- \-\-iface=enp0s8/g' kube-flannel.yml
$ sed -e 's/kube-subnet-mgr/kube-subnet-mgr\n        \- \-\-iface=enp0s8/g' kube-flannel.yml
$ kubectl apply -f kube-flannel.yml
$ kubectl get node
NAME     STATUS   ROLES    AGE    VERSION
master   Ready    master   111m   v1.18.1
```

## Next step is create worker node1

```
$ cd k8s-practice/node1 && vagrant up
$ vagrant ssh
$ sudo kubeadm join 192.168.100.10:6443 --token tftn6v.l2lk120fptpvn2l1 --discovery-token-ca-cert-hash sha256:4ca2xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
$ exit
$ kubectl get node -o wide
NAME     STATUS   ROLES    AGE     VERSION   INTERNAL-IP      EXTERNAL-IP   OS-IMAGE       KERNEL-VERSION     CONTAINER-RUNTIME
master   Ready    master   7h1m    v1.18.1   192.168.100.10   <none>        Ubuntu 19.10   5.3.0-42-generic   docker://19.3.8
node1    Ready    <none>   2m41s   v1.18.1   192.168.100.11   <none>        Ubuntu 19.10   5.3.0-42-generic   docker://19.3.8
```

- if you forgot discovery-token or you could'nt use discovery-token(token available 24 hours)

```
$ cd k8s-practice/master && vagrant ssh
$ kubeadm token create --print-join-command
```

## Next step is create worker node2
$ cd k8s-practice/node2 && vagrant up

```
$ cd k8s-practice/node2 && vagrant up
$ vagrant ssh
$ sudo kubeadm join 192.168.100.10:6443 --token tftn6v.l2lk120fptpvn2l1 --discovery-token-ca-cert-hash sha256:4ca2xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
$ exit
$ kubectl get node -o wide
NAME     STATUS   ROLES    AGE     VERSION   INTERNAL-IP      EXTERNAL-IP   OS-IMAGE       KERNEL-VERSION     CONTAINER-RUNTIME
master   Ready    master   7h40m   v1.18.1   192.168.100.10   <none>        Ubuntu 19.10   5.3.0-42-generic   docker://19.3.8
node1    Ready    <none>   41m     v1.18.1   192.168.100.11   <none>        Ubuntu 19.10   5.3.0-42-generic   docker://19.3.8
node2    Ready    <none>   2m40s   v1.18.1   192.168.100.12   <none>        Ubuntu 19.10   5.3.0-42-generic   docker://19.3.8
```

## Create Kubernetes Dashboard
- refs: https://github.com/kubernetes/dashboard

```
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-rc7/aio/deploy/recommended.yaml
$ kubectl proxy
```

- create account
    - https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md

```
$ cd k8s-practice/config
$ kubectl apply -f kubernetes-dashboard-create-user.yml
```

- get token

```
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
```

- login to Kubernetes Dashboard

```
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```