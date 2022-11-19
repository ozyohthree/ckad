Environment Prep

k get all -A (all resources all namespaces)'

k config set-context mycontext --namespace=somenamespace

alias k=kubectl
export do=”--dry-run=client -o yaml”
export now=”--force –grace-period 0”
export rff="replace --force -f" 

export ns=default
alias k='kubectl -n $ns' # This helps when namespace in question doesn't have a friendly name 
alias kdr='kubectl -o yaml --dry-run=client ' .  # run commands in dry run mode and generate yaml.
alias kgp="k get pods "
alias kgpy="k get pods -o yaml "
alias krf="kubect replace --force -f "

VIM Prep
vim ~/.vimrc   # then add:
syntax on
set nu
set expandtab
set tabstop=2
set shiftwidth=2

VIM Tips
Ctrl V - visual mode to select large blocks of text
dd - delete a line
dG - delete from cursor to EOF
ZZ - save and exit
6>> - indent 6 lines
:w - Save file.
:x or SHIFT ZZ - Save and exit.
:q  - Exit if no changes have been made.
:q!  - Exit and undo any changes made.
:set nu - Display line numbers.


$ kubectl explain pods --recursive | less

$ k get all --selector env=prod #get everything labeled env: prod
$ k get all --no-headers | wc -l #count lines

$ kubectl run nginx --image=nginx --restart=Never --dry-run=client -o yaml > mypod.yaml
OR
$ k run nginx --image=nginx --restart=Never $do > mypod.yaml


$ kubectl create deployment nginx --image=nginx -- date #deployment
$ k create deployment deply --image=nginx -r 2 --port=8080 --dry-run=client -o yaml -- sh -c "sleep 3600" > test.yaml
$ kubectl run nginx --image=nginx --restart=Never  #pod
$ kubectl create job nginx --image=nginx  #job
$ kubectl create cronjob nginx --image=nginx --schedule="* * * * *"  #cronJob

#deployment rollout
$ kubectl rollout status deployment/mydeploy
$ k rollout history deploy mydeploy


#To run a temp pod to test curl a service
$ k run tmp --restart=Never --rm -i --image=nginx:alpine -- curl 10.44.0.78

INGRESS
# create ingress resources
# kubectl create ingress <ingress-name> --rule="host/path=service:port"
$ kubectl create ingress ingress-test --rule="wear.my-online-store.com/wear*=wear-service:80"




________________


Pods


apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: ektest
  name: ektest
spec:
  containers:
  - image: nginx:latest
    name: ektest
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
________________




Deployments


apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: ektestdep
  name: ektestdep
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ektestdep
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: ektestdep
    spec:
      containers:
      - image: nginx:latest
        name: nginx
        command: ["sh", "-c", "tail -f /var/log/cleaner/cleaner.log"]   
        volumeMounts:                                                   
        - name: logs                                                    
          mountPath: /var/log/cleaner                                   
________________


Config Maps


$ kubectl create configmap app-config --from-literal=key123=value123


spec:
  containers:
  - image: nginx
    name: nginx
    env:                          #direct key value
    - name: KEY_NAME
      value: VALUE_NAME
    - name: KEY_NAME2             # get value from configmap
      valueFrom:
        configMapKeyRef:
          name: CONFIMAP_NAME
          key: CONFIGMAP_KEY_NAME
    - name: KEY_NAME3             # get value from secret
      valueFrom:
        secretKeyRef:
          name: SECRET_NAME
          key: SECRET_KEY
    envFrom:                      # get all from configmap
    - configMapRef:  
        name: confimap-name 
    - secretRef:
        name: secret-name
    envFrom:                       # get all from secret
    - configMapRef:
        name: app-config






Secrets


$ kubectl create secret generic my-secret --from-literal=foo=bar -o yaml --dry-run > my-secret.yaml


$ echo "YmFy" | base64 --decode  # command to decode the secret




# secret.yaml
apiVersion: v1
data:
  foo: YmFy
kind: Secret
metadata:
  creationTimestamp: null
  name: my-secret


# Mounting a secrets to a pod
apiVersion: v1
kind: Pod
metadata:
  name: secrets-test-pod
spec:
  containers:
  - image: nginx
    name: test-container
    volumeMounts:
    - mountPath: /etc/secret/volume
      name: secret-volume
    env:
    - name: SECRET1_USER              
      valueFrom:                      
        secretKeyRef:                 
          name: secret1               
          key: user      
  volumes:
  - name: secret-volume
    secret:
      secretName: my-secret






Security Contexts


apiVersion: v1
kind: Pod
spec:
  securityContext:
    runAsUser: 1000
  containers:
  - name: sec-ctx-demo
    image: gcr.io/google-samples/node-hello:1.0
    securityContext:
      runAsUser: 2000
      allowPrivilegeEscalation: false




Resource Request


apiVersion: v1
kind: Pod
spec:
  containers:
  - name: demo
    image: polinux/stress
    resources:
      limits:
        memory: 200Mi
        cpu: 200m
      requests:
        memory: 100Mi
        cpu: 100m




Deployment Updates


$ kubectl rollout status deploy/nginx
$ k rollout undo deploy/nginx
$ k rollout history deploy/nginx




Services


$ kubectl expose pod pod_name --name=svc_name --port=8080 --target-port=80


Jobs and Cron Jobs


$ kubectl create cronjob bespin --image=alpine --schedule="*/5 * * * *" -- date    # runs the date command


apiVersion: batch/v1beta1
kind: CronJob
metadata:
  labels:
    run: crontest
  name: crontest
spec:
  schedule: '*/1 * * * *'
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - image: busybox
            name: crontest
            command: ["date; echo Hello"]
        # Or command: ['sh', '-c', 'sleep 2 && echo "done"']
          restartPolicy: OnFailure




Init Containers


     initContainers:                
      - name: init-con
        image: busybox:1.31.0
        command: ['sh', '-c', 'echo "check this out!" > /tmp/web-content/index.html']
        volumeMounts:
        - name: web-content
          mountPath: /tmp/web-content


Labels
kubectl get pod –show-labels


kubectl get pod -l key=value                # to get pods with this specific label


kubectl label pods my-pod new-label=awesome              # Add a label


kubectl annotate pods my-pod icon-url=http://goo.gl/XXBTWq       # Add an annotation




Helm Charts


$ helm ls   # list charts


$ helm ls -a   # list all charts including those stuck in Pending


$ helm uninstall chart-name    # delete a release


$ helm repo list    # list the repo


$ helm repo update         # update the charts from the repo


$ helm search repo chart-name   # search the repo for a chart


$ helm upgrade chart-name repo-name        # e.g. helm upgrade nginx-chart bitnami/nginx


$ helm rollback


$ helm install chart-name repo-name                # e.g. helm install nginx-chart bitnami/nginx




Docker and Podman


$ sudo docker build -t repo/name:latest .

$ sudo docker push repo/name:latest

$ podman build -t registry.killer.sh:5000/sun-cipher:v1-podman .

$ podman push registry.killer.sh:5000/sun-cipher:v1-podman

$ podman ps

$ podman logs

$ podman run –name mycontainer -d repo/image:latest   # -d is for the background




Persistent Volumes


apiVersion: v1
kind: PersistentVolume
metadata:
  name: earth-project-earthflower-pv
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /Volumes/Data


PVC

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: earth-project-earthflower-pvc
  namespace: earth
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
________________


k get po nginx -o jsonpath='{.spec.containers[].ports[].containerPort}{"\n"}'

$ NGINX_PODIP=$(k get po nginx -o jsonpath='{.status.podIP}')

k run busybox --image=busybox --env="NGINX_IP=$NGINX_PODIP" --rm -it --restart=Never -- sh -c 'wget -O- $NGINX_IP:80'







Useful Resources


Katacoda Practice Lab: https://www.katacoda.com/liptanbiswas/courses/ckad-practice-challenges/


Exam Prep: https://github.com/twajr/ckad-prep-notes


Practice Questions: https://thospfuller.com/2020/11/09/answers_to_five_kubernetes_ckad_practice_questions_2021/