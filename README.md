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
$ cd k8s-practice/node1 && vagrant up

## Next step is create worker node2
$ cd k8s-practice/node2 && vagrant up
