# Lab Setup & Installation

Kubernetes (kubectl) Install : 

1. https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management WSL 
2. On WSL install KIND (Kubernetes in Docker) which uses docker 
    1. 
    
    Step 1 - fix docker group command (optional but good)
    
    ```bash
    sudo usermod -aG docker$USER
    ```
    
    Then fully restart the WSL distro from Windows:
    
    - Open PowerShell (as your user) and run:
    
    ```powershell
    wsl--shutdown
    ```
    
    Then open Ubuntu again.
    
    Step 2 - use Docker Desktop (Windows) as the Docker daemon
    
    1. Install or open Docker Desktop on Windows
    2. Settings -> Resources -> WSL Integration -> enable your Ubuntu-22.04 distro
    3. Back in WSL, run:
    
    ```bash
    docker version
    docker ps
    ```
    
    If docker ps works, youre good.
    
    Step 3 - install kind and create a cluster
    
    ```bash
    curl -Lo kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
    chmod +x kind
    sudo mv kind /usr/local/bin/kind
    
    kind create cluster --name lab
    kubectl get nodes
    kubectl get pods -A
    
    ```
    

[Kubernetes Lab Cleanup Procedure](Kubernetes%20Lab%20Cleanup%20Procedure%203072556d80ae8031981bf4f6e1b342e4.md)