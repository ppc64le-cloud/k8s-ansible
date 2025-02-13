# k8s-ansible : Ansible utility to deploy alpha/release version Kubernetes clusters.

#### Deploying a stable Kubernetes cluster

##### Method 1: Update fields in both hosts.yml and extra-vars-k8s.json to deploy cluster

Modify the host entry in the examples/containerd-cluster/hosts.yml and modify extra_cert in examples/containerd-cluster/extra-vars-k8s.json
```shell script
ansible-playbook -i examples/containerd-cluster/hosts.yml install-k8s.yml --extra-vars "@examples/containerd-cluster/extra-vars-k8s.json"
```

##### Method 2: Deploy using hack/k8s-installer.sh for alpha/release Kubernetes installation
The k8s-installer.sh utility under hack, provides an option to choose between the latest release or the alpha version of Kubernetes to be deployed on VMs from the hack directory.
###### Example usages:
```shell
./k8s-installer.sh -c X.X.X.X -w Y.Y.Y.Y -p <playbook to use> -a|-r -y
```
To deploy latest Alpha release of k8s:
```shell
./k8s-installer.sh -w X.X.X.X -c Y.Y.Y.Y -a -y
```
To deploy latest Stable release of k8s:
```shell
./k8s-installer.sh -w X.X.X.X -c Y.Y.Y.Y -r -y
```
To deploy latest Stable release of k8s for perf-tests:
```shell
./k8s-installer.sh -p install-k8s-perf.yml -w X.X.X.X -c Y.Y.Y.Y -r -y
```

