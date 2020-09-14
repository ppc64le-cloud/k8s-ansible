# k8s-ansible

#How to use

## Deploy a stable k8 cluster

```shell script
# modify the host entry in the examples/stable-cluster/hosts.yaml and modify extra_cert in examples/stable-cluster/extra-vars-k8s-stable.json 
$ ansible-playbook -i examples/stable-cluster/hosts.yml install-k8s.yml --extra-vars "@examples/stable-cluster/extra-vars-k8s-stable.json"
```