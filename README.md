# k8s-ansible

#How to use

## Deploy a stable k8 cluster

```shell script
# modify the host entry in the examples/containerd-cluster/hosts.yaml and modify extra_cert in examples/containerd-cluster/extra-vars-k8s-stable.json 
$ ansible-playbook -i examples/containerd-cluster/hosts.yml install-k8s.yml --extra-vars "@examples/containerd-cluster/extra-vars-k8s-stable.json"
```
