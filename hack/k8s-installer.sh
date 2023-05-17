#!/bin/bash
#
# Hack script to install and set up Kubernetes cluster using ansible-playbook
# Validates the IPs, deploys k8s on nodes (Alpha/release) based on args.
# Deploys the cluster based on the playbook passed as argument (default: install-k8s.yml)

# Path to playbooks, extra-vars and host files.
project_dir=$(dirname $(pwd))
var_file=$project_dir/examples/containerd-cluster/extra-vars-k8s.json
hosts_file=$project_dir/examples/containerd-cluster/hosts.yml

# Regex for validating IPs.
binary_octet='([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))'

# Default values for variables used in script.
release="false"
alpha="false"
approve="n"

# help_function : Returns the usage guide for script.
help_function()
{
cat <<EOF

Usage: $0 -p <playbook> -c <IP> -w <IP>

   ./test.sh -w X.X.X.X -c X.X.X.X -p install-k8s-perf.yml -a -y

   -p: Playbook to use.
       Default - install-k8s.yml; use install-k8s-perf.yml to set up the perf-tests cluster.
   -c IP address of the control-plane.
   -w IP address(es) of the worker-nodes.
      Eg: X.X.X.X for a single node or "X.X.X.X Y.Y.Y.Y" for multinode in quotes.
   -r Use the latest stable-release for cluster deployment.
   -a Use the latest alpha-release for cluster deployment.
   -y Proceed to run playbook to deploy k8s-cluster after generating fields.
EOF
exit 1
}

# check_reachability: Validates and pings the machine IPs.
check_reachability()
{
  ip_addressess=("$@")
  for ip_address in $ip_addressess; do
  if [[ "$ip_address" =~ ^($binary_octet\.){3}$binary_octet$ ]]; then
    ping -c1 $ip_address 1>/dev/null
    if [ $? -eq 0 ]; then
      echo "$ip_address is reachable"
      echo $ip_address >> $hosts_file
    else
      echo "$ip_address is not reachable"
      exit -1
    fi
  else
    echo "Invalid IP $ip_address"
    exit -1
  fi
  done < <(echo "$ip_address")
}

# write_to_extravars: Add changes to extra-vars-k8s.json for deploying k8s cluster
write_to_extravars()
{
  sed -i \
  -e "s/  \"directory\": .*/  \"directory\": \"$directory\",/" \
  -e "s/  \"build_version\": .*/  \"build_version\": \"$version\",/" \
  -e "s/  \"release_marker\": .*/  \"release_marker\": \"$release_marker\",/" \
  -e "s/  \"extra_cert\": .*/  \"extra_cert\" : \"$controllers\",/" \
  $var_file
}

# Flush contents of hosts.yml file to hold control-plane and worker IPs
>$hosts_file

# Process arguments
while getopts "ac:p:rw:y" opt; do
  case "$opt" in
    p)
      playbook="$OPTARG";;
    c)
      controllers=("$OPTARG")
      echo "[masters]" >> $hosts_file
      check_reachability $controllers;;
    w)
      workers=("$OPTARG")
      echo "[workers]" >> $hosts_file
      check_reachability "${workers[@]}";;
    a)
      alpha="true"
      echo "Fetching latest k8s Alpha CI version."
      version=$(curl -Ls https://dl.k8s.io/ci/latest.txt)
      release_marker="ci\/latest"
      directory="ci"
      write_to_extravars
      echo "Alpha release version to be used for cluster deployment: $version";;
    r)
      release="true"
      echo "Fetching latest k8s stable release version."
      version=$(curl -Ls https://dl.k8s.io/release/stable.txt)
      release_marker="$version"
      directory="release"
      write_to_extravars
      echo "Stable release version to be used for cluster deployment: $version";;
    y)
      approve="y"
      echo "Approved to run playbooks after initialization";;
    *)
      # print the help message if unrecognized/no parameters are passed.
      help_function ;;
  esac
done

# Print help_function in case parameters are empty
if [ -z "$workers" ] || [ -z "$controllers" ]
then
  echo "Control-plane/worker node IP was not provided as input arguments."
  help_function
elif [ "$alpha" == "$release" ]; then
  echo "Either -a or -r needs to be used to deploy alpha or release version of k8s."; exit
fi

if [ -z "$playbook" ]; then
  echo "No playbook has been passed, defaulting to install-k8s.yml"
  playbook="install-k8s.yml"
else
    echo "Playbook \"$playbook\" to be used to set up cluster"
fi

echo "Ansible Playbook   : $playbook"
echo "Control Node IP    : $controllers"
echo "Worker Node IP(s)  : $workers"

# A check to prevent execution of playbook unless approved through -y flag,
# To  modify the generated fields in extra-vars file and deploy through method 1 if needed
if [ "$approve" == "n" ]; then
    read -p "Approval flag was not set, proceed to run playbook? [y/n]: " approve  && [ $approve  == "y" ] || exit 1
fi

# Run the playbook post validation.
ansible-playbook -i $hosts_file  $project_dir/$playbook --extra-vars "@$var_file"
