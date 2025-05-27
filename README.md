| Resource| Specs                                    | Role                          | IP Address        |
| --------| ---------------------------------------- | ------------------------------| ------------------|
| **VM1** | 4vCPU, 16GB RAM, `Ubuntu Server 22.04.5` | Kubernetes + Istio + Services | `192.168.122.49`  |
| **VM2** | 2vCPU, 4GB RAM, `Ubuntu Server 22.04.5`  | Keycloak + PostgreSQL (auth)  | `192.168.122.155` |
| **VM3** | 2vCPU, 4GB RAM, `Ubuntu Server 22.04.5`  | PostgreSQL (Service Database) | `192.168.122.154` |

# Getting Started
## VM1
### Install K3s
Kubernetes will be installed using K3s because of resource constraint
```
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
    --cluster-cidr=10.42.0.0/16 \
    --service-cidr=10.43.0.0/16 \
    --disable=traefik \
    --node-ip=192.168.122.49 \
    --tls-san=$(hostname -I | awk '{print $1}') \
    --tls-san=192.168.122.49" sh -
```
note:
- set ` --node-ip ` to your vm or server ip that will run kubernetes (in this setup it running in VM1 `192.168.122.49`)
- K3s by default are using traefik for ingress controller, since we will be using `istio ingress gateway` we will disable `traefik`


### Setup VM or Server Environtment for kubernetes
```
sudo mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
chmod 600 $HOME/.kube/config
echo 'export KUBECONFIG=$HOME/.kube/config' >> ~/.bashrc
source ~/.bashrc
```
check if Kubernetes is running
```
kubectl get nodes -o wide
```
note:
- replace `~/.bashrc` with `/.zshrc` if you use Zsh
