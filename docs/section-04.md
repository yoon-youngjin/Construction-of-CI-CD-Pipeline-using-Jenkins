# Jenkins + Ansible + Kubernetes 연동

## Kubernetes 소개 

### Container Virtualization

![image](https://user-images.githubusercontent.com/83503188/189601001-63eeb1f7-0be4-4911-acc6-4fdd9c886dc9.png)

- Traditional Deployment
   - 전통적인 방법을 통해서 어플리케이션을 배포한다는 것
   - 물리적인 하드웨어 위에 운영체제를 설치하고 필요로하는 어플리케이션을 설치하는 방식
   - 하나의 물리적인 서버가 가지고 있는 리소스를 여러가지 어플리케이션이 공유하는 방식이며 특정 어플리케이션이 리소스를 많이 점유한다면 다른 어플리케이션의 성능이 떨어짐

- Virtualized Deployment  
  - 서버 가상화 방식
  - 물리적인 하드웨어 위에 운영체제를 설치하고 **Hypervisor**라는 기술을 통해서 각각의 VM에 개별적인 운영체제를 운영할 수 있다.
  - 서버 가상화는 결국 물리적인 하드웨어가 가진 리소스를 쪼개서 가상화에 있는 VM들이 사용하는것이므로 VM이 늘어날 수록 서버에 무리가감

> 개별적인 운영체제 운영?
>
> CPU, Memory, 프로세스 .. 등등 각각의 VM간에 독립적으로 운영하기 때문에 VM안에 설치된 어플리케이션간에 어느정도의 보안도 유지가능함.

- Container Deployment 
  - VM가 유사하지만 격리하는 부분에 대해서 완화, 어플리케이션간의 운영체제를 공유할수 있도록 해주는 가상화 기술
  - 운영체제에 필요한 리소스를 서비스간에 공유함으로써 컨테이너 가상화 기술은 서버 가상화 기술에 비해서 훨씬 가볍게 어플리케이션을 운영할 수 있게 되었다.
  - 기존 인프라의 종속성을 분리할 수 있었으므로 다양한 클라우드에 이식하여 운영이 가능해졌다.

### Kubernetes

- Docker는 k8s를 대신할 수 없고, k8s는 Docker를 대신할 수 없다.
- 오픈소스 기반의 컨테이너화 된 애플리케이션(워크로드와 서비스)의 자동 배포, 스케일링 등을 제공하는 관리 플랫폼
- 각각의 컨테이너를 관리해주며 스케줄링해주는 도구
- Kubernetes를 통해서 Docker에 배포된 결과물을 관리하는 도구로 사용할 것이다.

- 장점과 단점

![image](https://user-images.githubusercontent.com/83503188/189604014-eabcc852-c80f-4640-af3c-d978af8581f8.png)

### Kubernetes Cluster

![image](https://user-images.githubusercontent.com/83503188/202840240-86f9cde0-6c7d-40c7-b671-5b23d5876a33.png)

- Work 노드와 Work 노드를 관리해주는 Master 노드를 묶어서 k8s Cluster라고 한다.
- k8s의 Master 노드에서는 전체 구성되어있는 각각의 노드(PC)를 관리하기 위한 용도
- 실제로 컨테이너 자체를 운영하고 컨테이너에 대한 스케줄링 해주는 작업을 Work 노드라고 한다.
- Master 노드안에는 설정 정보, 사용자의 스케줄 관리, api, .. 을 처리할 수 있도록 구성되어 있다.
- 각각의 노드들은 실제로 운영하고자하는 컨테이너들을 관리하기 위한 Pod가 존재, Pod를 관리하기 위한 Kublet이라는 개념이 존재한다.
- 개발자, 운영자가 각각의 운영 툴로 명령어를 Master 노드의 api 서버에 전달되고, 전달된 api 서버는 가용할 수 있는 노드들에게 해당 명령어를 전달한다.
- 명령어를 전달받는 역할은 각 노드의 큐브 Proxy가 해준다. -> 큐브 Proxy는 Cluster의 각 노드에서 실행되고 있는 네트워크 Proxy
- 큐브 Proxy는 네트워크 유지, 관리를 해준다.
- 클라이언트(개발자, 운영자)가 요청한 정보가 Master 노드를 통해 각 노드에 전달되면 사용자들은 각 노드에서 애플리케이션, 서비스를 사용할 수 있는 구조

### Working of Kubernetes

![image](https://user-images.githubusercontent.com/83503188/189605628-4559ee7f-3043-4a12-ba33-0266820639e3.png)

- 사용할 수 있는 컨테이너를 Pod 형태로 묶어서 사용하는것이 일반적인 형태
- Docker의 컨테이너 != Pod -> 여러가지 컨테이너가 묶여서 Pod를 구성한다.
- 각 노드들은 컨테이너를 운영하기 위한 컨테이너 엔진(Docker)이 존재해야 한다.

CI/CD pipeline을 통해서 결과물을 배포한다는 의미는 일단 컨테이너형태로 배포할 것인데 그러한 컨테이너는 Pod라는 것으로 감싸서 배포

Pod형태로 감싸진 결과물을 외부에서 사용할 수 있도록 서비스라는 오브젝트가 붙어서 사용할 수 있는 상태로 만들어준다.

- Pods: 애플리케이션을 위해 서로 상호 작용해야 하는 컨테이너들의 논리적인 집합
- Service: Replicated 된 PODS 그룹 간에 로드 밸런싱을 제공


## K8s 기본 명령어

**노드 확인**
```text
kubectl get nodes
```

**Pod 확인**
```text
kubectl get pods
```

**Deployment 확인**
```text
kubectl get deployments
```

**Service 확인**
```text
kubectl get services
```

**Nginx 서버 실행**
```text
kubectl run sample-nginx --image=nginx --port=80
```

**컨테이너 정보 확인**
```text
kubectl describe pod/sample-nginx
```

**파드 삭제**
```text
kubectl delete pod/sample-nginx-XXXXX-XXXXX
```

**Scale 변경 (2개로 변경)**
```text
kubectl scale deployment sample-nginx --replicas=2
```

**Script 실행**
```text
kubectl apply -f sample1.yml
```

> namespace?
> 
> namespace 라는 개념은 가상의 네트워크, k8s의 오브젝트들이 모여있는 가상의 공간

**kubectl 명령어를 통해서 Nginx라는 웹서버를 다운로드 받아서 컨테이너 방식으로 기동**
```text
kubectl run sample-nginx --image=nginx --port=80
```

- k8s를 사용할 때는 컨테이너가 이미 작동 중 이어야하며 k8s에서 관리하고자하는 최소 단위는 Pod
- Pod 내에는 실행하고자하는 서비스, 미들웨어, 운영체제, 어플리케이션 등이 컨테이너로 패키징화 되어있어서 사용할 수 있는 상태
- 위의 예제는 nginx라는 웹서버가 이미지형태로 제공되고있는데 해당 이미지를 가져와서 sample-nginx라는 Pod로 생성하겠다는 명령어

![image](https://user-images.githubusercontent.com/83503188/202841769-6ea30743-fc82-4306-86cf-b8c0705e7cf3.png)

**위에서 실행한 Nginx를 설치**
```text
kubectl create deployment sample-nginx --image=nginx
```
- Deployment라는 개념을 통해서 방금 실행한 nginx를 설치
- Deployment: 가지고 있는 pod를 여러개의 형태로 스케일링하거나 스케줄링작업, 히스토리작업을 할 때 사용할 수 있는 설치 개념
- Deployment 시 자동으로 pod가 생성되고 pod를 생성해도 다른 아이디를 가진 pod가 자동 생성된다.
- Deployment도 Pod를 배포하는 개념

![image](https://user-images.githubusercontent.com/83503188/202842043-d7e86cea-85e3-4211-9ebe-f394dee29558.png)

- Deloyment 형태로 Pod가 생성되면 이름 뒤에 랜덤 숫자가 배정된다. 
- 즉, sample-nginx 라는 Deployment 에는 Pod 한개가 묶여서 실행되고 있다.

![image](https://user-images.githubusercontent.com/83503188/202842143-ef6964ed-fcb2-4525-b1ad-5df196e5a04c.png)

- Deploy 형태의 Pod를 삭제해도 새로운 랜덤 숫자가 배정된 Pod가 생성된다.
- Deplo 형태로 Pod를 실행하게 된다면 Deployment에서 유지하려고하는 최소한의 Pod 개수를 계속 유지해준다.
- 따라서 Pod 가 문제가 생겨서 정상 작동중이지 않을 경우에 반드시 최소한의 pod 개수를 유지하려는 속성을 가진다.

**스케일링 작업**
```text
kubectl scale deployment sample-nginx --replicas=2
```
- sample-nginx 에서 유지하려고 하는 Pod 개수를 2개로 지정하는 것

![image](https://user-images.githubusercontent.com/83503188/189621019-678d27d2-2f30-48a9-a2a2-88a356fecd82.png)

- 위의 READY가 의미하는 것은 현재 POD안에 전체 컨테이너 개수와 정상적으로 작동하는 컨테이너 개수를 의미한다.

![image](https://user-images.githubusercontent.com/83503188/189621570-bf41bd84-696d-4a1b-ab40-5272b035771a.png)

**Pod equal Container ? X**
- Pod 에는 하나의 컨테이너 이상이 들어갈 수 있다.

**위의 내용을 Script화하여 실행**
```text
kubectl apply -f sample1.yml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

- apiVersion: 어떤 오브젝트(Pod, Service, Deployment)따라 달라질 수 있지만 apps/v1이 거의 고정적으로 사용된다.
  - Pod, Service, Deployment -> apps/v1
- kind: 만들고자하는 k8s 오브젝트가 Pod? Deployment? Service? Replica-Set?
- metadata: 스크립트의 레이블링
- spec
  - kind 에 따라서 달라지는 정보
  - 예를 들어, Pod 인 경우에는 Pod 에 포함될 컨테이너 이름, ...
  - 현재 Deployment 이므로 Deployment 의 정보를 담은 것이다.
  - selector: 대상 정보, 작업하려는 대상을 어떤 Label에 명시할지 고른다.
  - template: 실제 Deployment 를 통해서 설치하려는 Pod의 내용

![image](https://user-images.githubusercontent.com/83503188/189623229-26a4cb82-5062-425a-ba64-fb7b4a4a9393.png)

## Kubernetes Script 파일

### k8s 기본 명령어
**Pod 상세 확인**
```text
kubectl get pod -o wide
```

**Pod 에 터널링으로 접속**
```text
kubectl exec -it nginx-deployment-XXXX-XXXX -- /bin/bash
```

**Pod 노출(공개)**
```text
kubectl expose deployment nginx-deployment --port=80 --type=NodePort
```
**Pod 삭제**
```text
kubectl delete pod/nginx-deployment-XXXX-XXXX
```

**Deployment 삭제**
```text
kubectl delete deployment nginx-deployment
```

**현재 Pod 가 사용하고 있는 Port를 외부에서 사용할 수 있는 형태(Service)로 오픈**

```text
 kubectl expose deployment same-nginx --port=8000 --type=NodePort
```
![image](https://user-images.githubusercontent.com/83503188/189626994-54630581-9b4d-42e8-a3ad-747798c276d1.png)
- 외부에서 사용할 수 있도록 노출하면 service 가 생성된다.
- 80:31464 -> 80: nginx 내부 포트, 31464: 외부 포트

![image](https://user-images.githubusercontent.com/83503188/202843377-20e27f8a-a262-4001-bd15-720ce6f3405f.png)

**위의 작업을 script화 - cicd-devops-deployment.yml**

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cicd-deployment
spec:
  selector:
    matchLabels:
      app: cicd-devops-project
  replicas: 2

  template:
    metadata:
      labels:
        app: cicd-devops-project
    spec:
      containers: # Section2,3에서 사용한 컨테이너
      - name: cicd-devops-project
        image: yoon11/cicd-project-ansible
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
        
```

- docker hub에서 다운로드 받아와서 k8s 환경에 기동할 것이다.

**위의 작업을 script화 - cicd-devops-service.yml**

```yml
apiVersion: v1
kind: Service
metadata:
  name: cicd-service
  labels:
    app: cicd-devops-project
spec:
  selector:
    app: cicd-devops-project
  type: NodePort
  ports:
    - port: 8080
      targetPort: 8080
      nodePort: 32000 
```
- Deployment 를 작동(외부에 공개)하기 위해서 작성하는 yml 파일
- 서비스는 외부의 특정한 포트를 공개하는 목적으로 주로 사용한다.
- 컨테이너가 가진 8080포트를 외부에 8080으로 공개하겠다.
- 실제 nodePort 사용할 때는 32000으로 접속

**실행**
```text
kubectl apply -f cicd-devops-deployment.yml
kubectl apply -f cicd-devops-service.yml
```

**결과**

![image](https://user-images.githubusercontent.com/83503188/189640522-5c03bcc2-ac9c-453f-8b2e-37f5ac4711a6.png)

![image](https://user-images.githubusercontent.com/83503188/202843668-3bf37d8a-1da3-4eb5-9f89-05963a362bdf.png)

## Kubernetes + Ansible 연동

**Ansible에서 Kubernetes 제어하기**

![image](https://user-images.githubusercontent.com/83503188/189641091-401b3a98-f5f6-46df-ae94-4fda4393fc41.png)

- Docker 컨테이너 운영중인 Ansible에서 k8s로 접속하여 Ansible의 playbook을 통해 k8s가 가진 yml파일을 실행할 것이다.
- hosts 파일에 kubernetes 그룹 추가

![image](https://user-images.githubusercontent.com/83503188/189641537-b3723488-22a7-47fd-a4c9-7eb7b90d1544.png)
- 이후에는 Jenkins에서 Ansible에 명령을 전달하면 Ansible에서 playbook파일을 통해 k8s에 필요한 명령어를 실행할 수 있게 된다.
- 또는 Jenkins에서 k8s로 직접 명령어를 실행할 수도 있다.

**ansible-server -> k8s-master 접속 테스트**

![image](https://user-images.githubusercontent.com/83503188/202843989-5ca51c2b-1184-4407-82cc-a267ff774308.png)

**Ansible hosts 파일 생성**

```text
[ansible-server]
localhost

[kubernetes]
192.168.2.10
```

**Ping Test**
```text
ansible -i ./k8s/hosts kubernetes -m ping -u vagrant
```

![image](https://user-images.githubusercontent.com/83503188/202844604-e6721383-de26-4e78-a421-2ef3974ff1e7.png)
- Ansible Server에서 k8s 서버에 패스워드를 입력하지 않았기 때문이다.
- 문제를 해결하기 위해서 키값을 k8s 서버에 복사 -> `ssh-copy-id vagrant@192.168.2.10`

![image](https://user-images.githubusercontent.com/83503188/202844710-aef654ee-00db-4725-aedb-5b3c2fe088da.png)

## Ansible Playbook으로 Kubernetes Script 실행하기 

**k8s Master) create a deployment yaml file - cicd-devops-deployment.yml**

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cicd-deployment
spec:
  selector:
    matchLabels:
      app: cicd-devops-project
  replicas: 2

  template:
    metadata:
      labels:
        app: cicd-devops-project
    spec:
      containers:
      - name: cicd-devops-project
        image: yoon11/cicd-project-ansible
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
```

**Ansible Server) create a playbook file for deployment - k8s-cicd-deployment-playbook.yml**

Ansible에서 Playbook 파일을 실행하여 k8s의 각각의 노드가 파일을 실행할 수 있도록 k8s에 필요한 script 생성

```yml
- name: Create pods using deployment
  hosts: kubernetes
  # become: true
  # user: ubuntu

  tasks:
  - name: delete the previous deployment
    command: kubectl delete deployment.apps/cicd-deployment
    ignore_errors: yes

  - name: create a deployment
    command: kubectl apply -f cicd-devops-deployment.yml
```

![image](https://user-images.githubusercontent.com/83503188/202844381-923e06fa-fccf-4534-a608-01acaf1fc792.png)

**Ansible Server) execute a playbook file(for deployment)**

```text
ansible-playbook -i ./k8s/hosts k8s-cicd-deployment-playbook.yml -u vagrant
```
- Ansible
![image](https://user-images.githubusercontent.com/83503188/202845065-5693d718-6bc9-4333-b29b-a51b9a6a013b.png)

- Kubernetes
![image](https://user-images.githubusercontent.com/83503188/202845113-7e6b4b11-659c-4abb-b6d9-6152e200f4cc.png)


**k8s Master) create a service yaml file - cicd-devops-service.yml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: cicd-service
  labels:
    app: cicd-devops-project
spec:
  selector:
    app: cicd-devops-project
  type: NodePort
  ports:
    - port: 8080
      targetPort: 8080
      nodePort: 32000
```

**Ansible Server) create a playbook file for service - k8s-cicd-service-playbook.yml**

```yaml
- name: create service for deployment
  hosts: kubernetes
  # become: true
  # user: ubuntu
  tasks:
    - name: delete the previous service
      command: kubectl delete service/cicd-service
      ignore_errors: yes

  - name: create a service
    command: kubectl apply -f cicd-devops-service.yml
```

**Ansible Server) execute a playbook file(for service)**

```text
ansible-playbook -i ./k8s/hosts k8s-cicd-service-playbook.yml -u vagrant
```

- Ansible
![image](https://user-images.githubusercontent.com/83503188/202845268-5a47cc5f-f4d1-456a-be32-d5f9f0aa914f.png)

- Kubernetes
![image](https://user-images.githubusercontent.com/83503188/202845302-8997753f-ade6-4ee6-857e-e07d9766cf60.png)

**결과**

![image](https://user-images.githubusercontent.com/83503188/202845323-b1e17a9e-e666-4104-82a6-f9d4f2da24a7.png)

## Jenkins + Ansible + Kubernetes 연동하기

![image](https://user-images.githubusercontent.com/83503188/202849846-76a4b1de-95f1-4354-89fa-ada70bf42323.png)

**Setup Ansible on Jenkins**

- Jenkins 관리 -> 시스템 설정 -> Publish over SSH

![image](https://user-images.githubusercontent.com/83503188/202849642-7cd98896-7bb7-4ea9-bc2d-fb8b6780203e.png)

- Item name: My-k8s-Project
- Build Triggers: SSH Server: k8s-master
- Exec command
```text
kubectl apply -f cicd-devops-deployment.yml
```

![image](https://user-images.githubusercontent.com/83503188/202850230-5c21bf9d-47f5-4378-a78f-c1b4a73b1559.png)

**결과**

![image](https://user-images.githubusercontent.com/83503188/202850262-523856d1-ec6d-45f6-a0a0-9f0811892b39.png)

- Item name -> My-k8s-Project-using-Ansible
- Build Triggers: SSH Server: ansible-server
- Exec command
```text
ansible-playbook -i ./k8s/hosts k8s-cicd-deployment-playbook.tml
```

![image](https://user-images.githubusercontent.com/83503188/202850363-8827960b-08d2-4ed6-a796-225dfc4e98b6.png)

**결과**

![image](https://user-images.githubusercontent.com/83503188/202851054-3768025d-426b-4cfc-989a-be859457e8a3.png)

- Append exec command
```text
ansible-playbook -i ./k8s/hosts k8s-cicd-deployment-playbook.tml
ansible-playbook -i ./k8s/hosts k8s-cicd-service-playbook.tml
```

**결과**

![image](https://user-images.githubusercontent.com/83503188/202851147-f241305e-3845-48c9-95c0-6c727a11a5d4.png)

## 전체 CI/CD 자동화 프로세스 구성

**Jenkins CI/CD Jobs**

![image](https://user-images.githubusercontent.com/83503188/202851266-d3029f61-0056-4690-8b84-b4ee162e15d2.png)

- CI 작업을 통해 최신 코드를 가지고 빌드된 결과물이 이미지화 되어서 Registry에 등록
- CD 작업을 통해 Registry 에 등록된 이미지를 설치하고자하는 서버에서 pull 받아서 해당 이미지를 통해 사용자가 사용할 수 있는 상태(service)로 만든다.

### CI

**create-cicd-devops-image-playbook.yml**

```yaml
- hosts: all
#   become: true

  tasks:
  - name: create a docker image with deployed waf file
    command: docker build -t yoon11/cicd-project-ansible .
    args: 
        chdir: /root
    
  - name: push the image on Docker Hub
    command: docker push yoon11/cicd-project-ansible

  - name: remove the docker image from the ansible server
    command: docker rmi yoon11/cicd-project-ansible  
    ignore_errors: yes
```

**Dockerfile**

```text
FROM tomcat:latest

COPY ./hello-world.war /usr/local/tomcat/webapps
```

**Ansible Playbook을 이용한 Docker Image 생성(CI job)**

- Item name -> My-K8s-Project-for-CI
- Build Trigger
  - Poll SCM: * * * * *
- Post-build Actions
  - SSH Server: ansible-sever
- Exec command
  - ansible-playbook -i ./k8s/hosts create-cicd-devops-image-playbook.yml --limit ansible-server
  - 이미지를 만들고 푸시하는 작업은 Ansible Server 에서만 한정

**결과**

![image](https://user-images.githubusercontent.com/83503188/202852093-6919bb90-cb97-4464-8bcc-83c01fe4ef03.png)
### CD

CI 작업을 통해 Registry 에 업로드된 이미지를 가지고 작업

- Post-build Actions
  - Build other projects: 현재 작업이 끝나고 빌드후에 다른 프로젝트를 또 다시 실행하겠다는 의미
    - Deploy on Kubernetes CD (CD job): My-K8s-Project-Ansible
    - Trigger only if builds is stable

**결과**

![image](https://user-images.githubusercontent.com/83503188/202852274-2b2a91dd-69fc-47a1-a946-d04089b7818e.png)

![image](https://user-images.githubusercontent.com/83503188/202852305-431d089a-59d5-40b2-9239-621b960da9aa.png)





