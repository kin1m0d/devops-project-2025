
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

``` sh
kubectl port-forward svc/argocd-server -n argocd 8082:443
```



## Grab the password:
``` sh
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```
Log in with "admin" and the retrieved password (8ImDJ8ejJN4NhvS4)


- Installed latest argocd on WSL2 https://argo-cd.readthedocs.io/en/stable/cli_installation/
``` sh
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```
``` sh
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


After pushing those changes

"Update Helm Chart with new image tag" fails
```
Run sed -i "s/tag:.*/tag: 581b0df/" ./complete-devops-project-time-printer/values.yaml
[master f91e3e5] Updated image tag to 581b0df
 1 file changed, 1 insertion(+), 1 deletion(-)
remote: Permission to kin1m0d/devops-project-2025.git denied to github-actions[bot].
fatal: unable to access 'https://github.com/kin1m0d/devops-project-2025/': The requested URL returned error: 403
Error: Process completed with exit code 128.
```


Error
```
dom@DESKTOP-DOM:~/git/devops-project-2025$ kubectl apply -f argocd-app.yaml
error: resource mapping not found for name: "devops-project-2025" namespace: "argocd" from "argocd-app.yaml": no matches for kind "Application" in version "argoproj.io.v1alpha1"
ensure CRDs are installed first
```

# Day 4 (29.10.2025)
pods are crashing
``` sh
dom@DESKTOP-DOM:~/git/devops-project-2025/terraform-configs$ kubectl get all -n argocd
NAME                                                    READY   STATUS             RESTARTS         AGE
pod/argocd-application-controller-0                     1/2     CrashLoopBackOff   56 (2m17s ago)   3d4h
pod/argocd-applicationset-controller-6bd77bd68d-z9f46   1/2     CrashLoopBackOff   36 (2m45s ago)   21h
pod/argocd-dex-server-64c5b56cd-2z7z6                   2/2     Running            2 (13m ago)      21h
pod/argocd-notifications-controller-57849d4f6-6885v     1/2     CrashLoopBackOff   36 (2m21s ago)   21h
pod/argocd-redis-7b6b96d579-kk52s                       1/1     Running            1 (13m ago)      21h
pod/argocd-repo-server-5c5c555c59-sl5gt                 1/2     CrashLoopBackOff   36 (2m49s ago)   21h
pod/argocd-repo-server-5f68784cff-ls8q6                 1/1     Running            4 (13m ago)      4d4h
pod/argocd-server-64b494c584-ltzc9                      1/2     CrashLoopBackOff   36 (2m3s ago)    21h
pod/argocd-server-8665c6885b-l4kfg                      1/1     Running            4 (13m ago)      4d4h
```


checking the pod logs
``` sh
dom@DESKTOP-DOM:~/git/devops-project-2025/terraform-configs$ kubectl logs argocd-application-controller-0 -n argocd
Defaulted container "argocd-application-controller" out of: argocd-application-controller, application-controller
time="2025-10-29T19:28:53Z" level=info msg="maxprocs: Leaving GOMAXPROCS=12: CPU quota undefined"
time="2025-10-29T19:28:53Z" level=info msg="ArgoCD Application Controller is starting" built="2025-10-17T21:35:08Z" commit=8665140f96f6b238a20e578dba7f9aef91ddac51 namespace=argocd version=v3.1.9+8665140
time="2025-10-29T19:28:53Z" level=info msg="Processing all cluster shards"
time="2025-10-29T19:28:53Z" level=info msg="Processing all cluster shards"
time="2025-10-29T19:28:53Z" level=info msg="appResyncPeriod=3m0s, appHardResyncPeriod=0s, appResyncJitter=1m0s"
time="2025-10-29T19:28:53Z" level=info msg="Starting configmap/secret informers"
time="2025-10-29T19:28:53Z" level=info msg="Configmap/secret informer synced"
time="2025-10-29T19:28:53Z" level=warning msg="The cluster https://kubernetes.default.svc has no assigned shard."
time="2025-10-29T19:28:53Z" level=info msg="Cluster https://kubernetes.default.svc has been assigned to shard 0"
time="2025-10-29T19:28:53Z" level=info msg="Ignore status for all objects"
time="2025-10-29T19:28:53Z" level=info msg="Using diffing customizations to ignore resource updates"
time="2025-10-29T19:28:53Z" level=info msg="Ignore status for all objects"
time="2025-10-29T19:28:53Z" level=info msg="0xc0004e4cb0 subscribed to settings updates"
time="2025-10-29T19:28:53Z" level=info msg="Starting secretInformer forcluster"
time="2025-10-29T19:28:53Z" level=fatal msg="listen tcp 0.0.0.0:8082: bind: address already in use"
```

I had used 8082 to expose the argocd server :|
let's use this instead
kubectl port-forward svc/argocd-server -n argocd 9999:443



``` sh
kubectl delete ns argocd
kubectl create ns argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

works now???
``` sh
dom@DESKTOP-DOM:~/git/devops-project-2025/terraform-configs$ kubectl get pods -n argocd
NAME                                                READY   STATUS    RESTARTS   AGE
argocd-application-controller-0                     1/1     Running   0          96s
argocd-applicationset-controller-86bfbfd54c-bqw57   1/1     Running   0          97s
argocd-dex-server-86bd88bb45-9r7ds                  1/1     Running   0          96s
argocd-notifications-controller-67cc46b754-6mhqc    1/1     Running   0          96s
argocd-redis-757f74dd67-g7c5b                       1/1     Running   0          96s
argocd-repo-server-584c99df7d-2qjjx                 1/1     Running   0          96s
argocd-server-5496498b9-q2pd4                       1/1     Running   0          96s
```

kubectl get all -n argocd
says all good as well, now we can forward the port again 

kubectl port-forward svc/argocd-server -n argocd 9999:443



Add the repo again 
```
dom@DESKTOP-DOM:~/git/devops-project-2025$ argocd repo add https://github.com/kin1m0d/devops-project-2025 --username kin1m0d --password "*******" --server localhost:9999 --insecure
Repository 'https://github.com/kin1m0d/devops-project-2025' added
dom@DESKTOP-DOM:~/git/devops-project-2025$
```



Still fails
``` sh
dom@DESKTOP-DOM:~/git/devops-project-2025$ kubectl apply -f argocd-app.yaml
error: resource mapping not found for name: "devops-project-2025" namespace: "argocd" from "argocd-app.yaml": no matches for kind "Application" in version "argoproj.io.v1alpha1"
ensure CRDs are installed first
```

Let's try to apply an older version??
``` sh
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.5.8/manifests/install.yaml
```


``` sh
dom@DESKTOP-DOM:~/git/devops-project-2025$ kubectl describe application devops-project-2025 -n argocd
Error from server (NotFound): applications.argoproj.io "devops-project-2025" not found
dom@DESKTOP-DOM:~/git/devops-project-2025$ kubectl get crds | grep argoproj
applications.argoproj.io      2025-10-25T15:11:19Z
applicationsets.argoproj.io   2025-10-25T15:11:19Z
appprojects.argoproj.io       2025-10-25T15:11:19Z


I'm a fool, turns out, this is wrong
apiVersion: argoproj.io.v1alpha1
and this is right....
apiVersion: argoproj.io/v1alpha1

``` sh
dom@DESKTOP-DOM:~/git/devops-project-2025$ kubectl apply -f argocd-app.yaml
application.argoproj.io/devops-project-2025 created
```

# Day 5 (30.10.2025)

In argocd I'll get the following sync error (https://localhost:9999/applications/argocd/devops-project-2025?view=tree&resource=&operation=true)

``` sh
ComparisonError: rpc error: code = Unknown desc = Manifest generation error (cached): `helm template . --name-template devops-project-2025 --namespace default --kube-version 1.34 --api-versions admissionregistration.k8s.io/v1 --api-versions admissionregistration.k8s.io/v1/MutatingWebhookConfiguration --api-versions admissionregistration.k8s.io/v1/ValidatingAdmissionPolicy --api-versions admissionregistration.k8s.io/v1/ValidatingAdmissionPolicyBinding --api-versions admissionregistration.k8s.io/v1/ValidatingWebhookConfiguration --api-versions apiextensions.k8s.io/v1 --api-versions apiextensions.k8s.io/v1/CustomResourceDefinition --api-versions apiregistration.k8s.io/v1 --api-versions apiregistration.k8s.io/v1/APIService --api-versions apps/v1 --api-versions apps/v1/ControllerRevision --api-versions apps/v1/DaemonSet --api-versions apps/v1/Deployment --api-versions apps/v1/ReplicaSet --api-versions apps/v1/StatefulSet --api-versions argoproj.io/v1alpha1 --api-versions argoproj.io/v1alpha1/AppProject --api-versions argoproj.io/v1alpha1/Application --api-versions argoproj.io/v1alpha1/ApplicationSet --api-versions autoscaling/v1 --api-versions autoscaling/v1/HorizontalPodAutoscaler --api-versions autoscaling/v2 --api-versions autoscaling/v2/HorizontalPodAutoscaler --api-versions batch/v1 --api-versions batch/v1/CronJob --api-versions batch/v1/Job --api-versions certificates.k8s.io/v1 --api-versions certificates.k8s.io/v1/CertificateSigningRequest --api-versions coordination.k8s.io/v1 --api-versions coordination.k8s.io/v1/Lease --api-versions discovery.k8s.io/v1 --api-versions discovery.k8s.io/v1/EndpointSlice --api-versions events.k8s.io/v1 --api-versions events.k8s.io/v1/Event --api-versions flowcontrol.apiserver.k8s.io/v1 --api-versions flowcontrol.apiserver.k8s.io/v1/FlowSchema --api-versions flowcontrol.apiserver.k8s.io/v1/PriorityLevelConfiguration --api-versions networking.k8s.io/v1 --api-versions networking.k8s.io/v1/IPAddress --api-versions networking.k8s.io/v1/Ingress --api-versions networking.k8s.io/v1/IngressClass --api-versions networking.k8s.io/v1/NetworkPolicy --api-versions networking.k8s.io/v1/ServiceCIDR --api-versions node.k8s.io/v1 --api-versions node.k8s.io/v1/RuntimeClass --api-versions policy/v1 --api-versions policy/v1/PodDisruptionBudget --api-versions rbac.authorization.k8s.io/v1 --api-versions rbac.authorization.k8s.io/v1/ClusterRole --api-versions rbac.authorization.k8s.io/v1/ClusterRoleBinding --api-versions rbac.authorization.k8s.io/v1/Role --api-versions rbac.authorization.k8s.io/v1/RoleBinding --api-versions resource.k8s.io/v1 --api-versions resource.k8s.io/v1/DeviceClass --api-versions resource.k8s.io/v1/ResourceClaim --api-versions resource.k8s.io/v1/ResourceClaimTemplate --api-versions resource.k8s.io/v1/ResourceSlice --api-versions scheduling.k8s.io/v1 --api-versions scheduling.k8s.io/v1/PriorityClass --api-versions storage.k8s.io/v1 --api-versions storage.k8s.io/v1/CSIDriver --api-versions storage.k8s.io/v1/CSINode --api-versions storage.k8s.io/v1/CSIStorageCapacity --api-versions storage.k8s.io/v1/StorageClass --api-versions storage.k8s.io/v1/VolumeAttachment --api-versions storage.k8s.io/v1/VolumeAttributesClass --api-versions v1 --api-versions v1/ConfigMap --api-versions v1/Endpoints --api-versions v1/Event --api-versions v1/LimitRange --api-versions v1/Namespace --api-versions v1/Node --api-versions v1/PersistentVolume --api-versions v1/PersistentVolumeClaim --api-versions v1/Pod --api-versions v1/PodTemplate --api-versions v1/ReplicationController --api-versions v1/ResourceQuota --api-versions v1/Secret --api-versions v1/Service --api-versions v1/ServiceAccount --include-crds` failed exit status 1: Error: template: complete-devops-project-time-printer/templates/httproute.yaml:1:14: executing "complete-devops-project-time-printer/templates/httproute.yaml" at <.Values.httpRoute.enabled>: nil pointer evaluating interface {}.enabled Use --debug flag to render out invalid YAML
```

I can't even be bothered to read this, luckily we have AI these days, which quickly tells me:

The error indicates that Helm failed to render the template complete-devops-project-time-printer/templates/httproute.yaml because it encountered a nil pointer error while trying to evaluate .Values.httpRoute.enabled. This typically happens when the httpRoute key is missing or not properly defined in the values.yaml file or when the template assumes a value that is not provided.


Now we can reproduce this manually by generating the helm template:

``` sh
dom@DESKTOP-DOM:~/git/devops-project-2025$ helm template . --name-template devops-project-2025 --namespace default
Error: chart file "terraform-provider-helm_v2.16.1_x5" is larger than the maximum file size 5242880
```

Which of course fails, but this seems like another issue...


``` sh
dom@DESKTOP-DOM:~/git/devops-project-2025$ find . -name "terraform-provider-helm_v2.16.1_x5"
./terraform-configs/.terraform/providers/registry.terraform.io/hashicorp/helm/2.16.1/linux_amd64/terraform-provider-helm_v2.16.1_x5
```

Okay this file is ignored by the .gitignore, but why the error???? Yeah I should run the command not from the project root directory, it will include ALL files.

``` sh
dom@DESKTOP-DOM:~/git/devops-project-2025$ helm template complete-devops-project-time-printer --name-template devops-project-2025 --namespace default
Error: template: complete-devops-project-time-printer/templates/httproute.yaml:1:14: executing "complete-devops-project-time-printer/templates/httproute.yaml" at <.Values.httpRoute.enabled>: nil pointer evaluating interface {}.enabled

Use --debug flag to render out invalid YAML
```

There we go, now we get pretty much the same error message as in argocd.


``` yaml
httpRoute:
  enabled: true
```
adding to values.yaml file


```
dom@DESKTOP-DOM:~/git/devops-project-2025$ helm template complete-devops-project-time-printer --name-template devops-project-2025 --namespace default --debug
install.go:225: 2025-10-30 22:22:11.907908786 +0000 GMT m=+0.160676395 [debug] Original chart version: ""
install.go:242: 2025-10-30 22:22:11.908394076 +0000 GMT m=+0.161161583 [debug] CHART PATH: /home/dom/git/devops-project-2025/complete-devops-project-time-printer


Error: template: complete-devops-project-time-printer/templates/hpa.yaml:1:14: executing "complete-devops-project-time-printer/templates/hpa.yaml" at <.Values.autoscaling.enabled>: nil pointer evaluating interface {}.enabled
helm.go:92: 2025-10-30 22:22:11.91240445 +0000 GMT m=+0.165172059 [debug] template: complete-devops-project-time-printer/templates/hpa.yaml:1:14: executing "complete-devops-project-time-printer/templates/hpa.yaml" at <.Values.autoscaling.enabled>: nil pointer evaluating interface {}.enabled
```

- I can debug with just adding --debug to helm template


- fixed typo
autoscaling:
  enabled: false


It seems that there are plenty errors coming from NOTES.txt, basically Helm throws those nil pointer errors if a varible is not declared in values.yaml. Checking the NOTES.txt in the repo used by the tutorial, it's much smaller. So I assume with newer version my auto generated NOTES.txt just has different variables, which is not covered by the tutorial. My lazy workaround is to exclude the file by renaming it to *.bak



The argocd syncing problem persists
``` sh
dom@DESKTOP-DOM:~/git/devops-project-2025$ kubectl get pods -n argocd
NAME                                               READY   STATUS    RESTARTS       AGE
argocd-application-controller-0                    1/1     Running   2 (114m ago)   26h
argocd-applicationset-controller-69777454d-nl42k   1/1     Running   2 (114m ago)   26h
argocd-dex-server-9fcc8cd6-qlhbj                   1/1     Running   2 (114m ago)   26h
argocd-notifications-controller-6c875d4fd4-w7z72   1/1     Running   2 (114m ago)   26h
argocd-redis-6f895956df-9l659                      1/1     Running   2 (114m ago)   26h
argocd-repo-server-7f745d844-jpv29                 1/1     Running   2 (114m ago)   26h
argocd-server-558bfbfcfb-bkslq                     1/1     Running   2 (114m ago)   26h
dom@DESKTOP-DOM:~/git/devops-project-2025$ kubectl -n argocd get applications
NAME                  SYNC STATUS   HEALTH STATUS
devops-project-2025   Unknown       Healthy
```


# Day 6 (31.10.2025)

password change: argocdadmin


Sync problem persits, because
httpRoute:
  enabled: true
doesn't exist, I probably have to just push the changes to the repo, but let's try to apply the changes manually

```
dom@DESKTOP-DOM:~/git/devops-project-2025$ argocd login localhost:9999 --username admin --password argocdadmin --insecure --grpc-web
{"level":"fatal","msg":"context deadline exceeded","time":"2025-10-31T20:31:07Z"}
dom@DESKTOP-DOM:~/git/devops-project-2025$ argocd version
argocd: v3.1.9+8665140
  BuildDate: 2025-10-17T22:07:41Z
  GitCommit: 8665140f96f6b238a20e578dba7f9aef91ddac51
  GitTreeState: clean
  GoVersion: go1.24.6
  Compiler: gc
  Platform: linux/amd64
{"level":"warning","msg":"Failed to invoke grpc call. Use flag --grpc-web in grpc calls. To avoid this warning message, use flag --grpc-web.","time":"2025-10-31T20:35:55Z"}
argocd-server: v2.5.8+bbe870f
dom@DESKTOP-DOM:~/git/devops-project-2025$
```

ChatGPT says:
That’s a major version gap (3.x vs 2.x).
The CLI introduced breaking changes in the gRPC/web handshake starting from Argo CD v3.0, meaning your newer CLI can’t talk to the older 2.5.x API — hence the:

context deadline exceeded
rpc error: code = Unauthenticated desc = no session information


apply fix
``` sh
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

``` sh
dom@DESKTOP-DOM:~/git/devops-project-2025$ kubectl get pods -n argocd
NAME                                                READY   STATUS        RESTARTS      AGE
argocd-application-controller-0                     1/1     Running       0             34s
argocd-applicationset-controller-86bfbfd54c-wxczg   1/1     Running       0             35s
argocd-dex-server-86bd88bb45-p9n54                  1/1     Running       0             35s
argocd-notifications-controller-67cc46b754-h2dnz    1/1     Running       0             34s
argocd-redis-757f74dd67-lzlfc                       1/1     Running       0             35s
argocd-repo-server-584c99df7d-mwwdm                 1/1     Running       0             35s
argocd-repo-server-7f745d844-jpv29                  1/1     Terminating   3 (83m ago)   2d
argocd-server-5496498b9-kqpql                       1/1     Running       0             34s
argocd-server-558bfbfcfb-bkslq                      1/1     Terminating   3 (83m ago)   2d
dom@DESKTOP-DOM:~/git/devops-project-2025$ kubectl get pods -n argocd
NAME                                                READY   STATUS    RESTARTS   AGE
argocd-application-controller-0                     1/1     Running   0          98s
argocd-applicationset-controller-86bfbfd54c-wxczg   1/1     Running   0          99s
argocd-dex-server-86bd88bb45-p9n54                  1/1     Running   0          99s
argocd-notifications-controller-67cc46b754-h2dnz    1/1     Running   0          98s
argocd-redis-757f74dd67-lzlfc                       1/1     Running   0          99s
argocd-repo-server-584c99df7d-mwwdm                 1/1     Running   0          99s
argocd-server-5496498b9-kqpql                       1/1     Running   0          98s
dom@DESKTOP-DOM:~/git/devops-project-2025$ argocd login localhost:9999 --username admin --password argocdadmin --insecure --grpc-we
b
'admin:login' logged in successfully
Context 'localhost:9999' updated
```

Sanity check
``` sh
dom@DESKTOP-DOM:~/git/devops-project-2025$ argocd account get-user-info
Logged In: true
Username: admin
Issuer: argocd
Groups:
dom@DESKTOP-DOM:~/git/devops-project-2025$ argocd app list
NAME                        CLUSTER                         NAMESPACE  PROJECT  STATUS   HEALTH   SYNCPOLICY  CONDITIONS       REPO                                            PATH                                  TARGET
argocd/devops-project-2025  https://kubernetes.default.svc  default    default  Unknown  Healthy  Auto-Prune  ComparisonError  https://github.com/kin1m0d/devops-project-2025  complete-devops-project-time-printer  HEAD
dom@DESKTOP-DOM:~/git/devops-project-2025$
```

Now I can finally log in with the argocd cli and on the web UI it doesn't stuck loading, but there is next error which seems familiar:

``` sh
ComparisonError: Failed to load target state: failed to generate manifest for source 1 of 1: rpc error: code = Unknown desc = Manifest generation error (cached): failed to execute helm template command: failed to get command args to log: `helm template . --name-template devops-project-2025 --namespace default --kube-version 1.34 <api versions removed> --include-crds` failed exit status 1: Error: template: complete-devops-project-time-printer/templates/httproute.yaml:1:14: executing "complete-devops-project-time-printer/templates/httproute.yaml" at <.Values.httpRoute.enabled>: nil pointer evaluating interface {}.enabled

Use --debug flag to render out invalid YAML
```


Pushed the changes, trying to sync, but 

```
The Kubernetes API could not find gateway.networking.k8s.io/HTTPRoute for requested resource default/devops-project-2025-complete-devops-project-time-printer. Make sure the "HTTPRoute" CRD is installed on the destination cluster.
```