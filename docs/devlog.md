
# Day 1 (23.10.2025)
- Started project on Windows WSL2
- Installed terraform on Windows
- Installed code extension "Terraform" from Anton Kulikov
- Installed docker desktop on Windows
- Installed k8 on Ubuntu https://gaganmanku96.medium.com/kubernetes-setup-with-minikube-on-wsl2-2023-a58aea81e6a3
- Installed code extension "GitHub Actions" from GitHub
- Generated dockerhub token and set secret in repo

# Day 2 (25.10.2025)
Found the error "push access denied, repository does not exist or may require authorization: server message: insufficient_scope: authorization failed"

"docker build -t kinimod311/devops-project-2025:test ." is correct not "kin1m0d" which is my guthub username

- Installed helm on Windows https://github.com/helm/helm/releases (not relly helpful for wsl)
- Installed helm on WSL2 https://www.adamhancock.co.uk/blog/install-helm-on-wsl/
- Needed to specify helm version
```
terraform {
    required_providers {
        minikube = {
            source  = "scott-the-programmer/minikube"
            version = "0.4.2"
        }
        helm = {
            source  = "hashicorp/helm"
            version = "2.16.1"
        }
    }
}
```

```
kubectl port-forward svc/argocd-server -n argocd 8081:443
Unable to listen on port 8081: Listeners failed to create with the following errors: [unable to create listener: Error listen tcp4 127.0.0.1:8081: bind: address already in use unable to create listener: Error listen tcp6 [::1]:8081: bind: address already in use]
error: unable to listen on any of the requested ports: [{8081 8080}]
```
```
PS C:\Users\dom> netstat -ano | findstr :8081
  TCP    [::1]:8081             [::]:0                 LISTENING       26668
PS C:\Users\dom> ps | findstr 26668
    166      12     1792       7728       0.02  26668   9 wslrelay
PS C:\Users\dom> netstat -ano | findstr :8082
PS C:\Users\dom>
```
8081 seems to be important for WSL, let's try 8082 instead which is free


# Day 3 (26.10.2025)
Set everything up to continue the project:
- Start Docker Desktop on Windows so that it's available on WSL2 Ubuntu machine
- minikube start


Forwards traffic from local machine to the argocd server in the minikube cluster
Map port 8082 to 443
(don't close the terminal session)

kubectl port-forward svc/argocd-server -n argocd 8082:443



Grab the password:
```
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

Log in with "admin" and the retrieved password


- Installed latest argocd on WSL2 https://argo-cd.readthedocs.io/en/stable/cli_installation/
``` sh
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```
```
dom@DESKTOP-DOM:~/git/devops-project-2025$ argocd version
argocd: v3.1.9+8665140
  BuildDate: 2025-10-17T22:07:41Z
  GitCommit: 8665140f96f6b238a20e578dba7f9aef91ddac51
  GitTreeState: clean
  GoVersion: go1.24.6
  Compiler: gc
  Platform: linux/amd64
{"level":"fatal","msg":"Argo CD server address unspecified","time":"2025-10-26T13:45:17Z"}
```
Terminal login
```
dom@DESKTOP-DOM:~/git/devops-project-2025$ argocd login localhost:8082 --username admin --password HSAINn9m-vaz6Kpv --insecure
'admin:login' logged in successfully
Context 'localhost:8082' updated
```


- Create token in Github account https://github.com/settings/tokens
- Add repo to argocd
```
dom@DESKTOP-DOM:~/git/devops-project-2025$ argocd repo add https://github.com/kin1m0d/devops-project-2025 --username kin1m0d --password "my_github_token" --server localhost:8082 --insecure
Repository 'https://github.com/kin1m0d/devops-project-2025' added
```






