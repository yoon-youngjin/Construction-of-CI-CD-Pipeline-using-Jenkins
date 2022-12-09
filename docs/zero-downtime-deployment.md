# Ansible을 이용한 무중단 배포

1. 파일을 통해 현재 Service 가 바라보고 있는 버전 관리
2. 파일을 읽어와서 반대 방향에 Deployment 삭제 후 생성
   1. 현재 방향이 Blue 인 경우에 Green 에 배포 진행
3. `kubectl rollout` 명령어를 통해 Ready 상태 대기
4. 파일을 읽어와서 생성된 Deployment 로 방향 변경
5. `switch.sh` 실행하여 버전 관리 파일 변경

### 1.파일을 통해 현재 Service 가 바라보고 있는 버전 관리 

**sysctl_param.yml**
```yaml
color: green
```

- 현재 Service 가 green 버전으로 트래픽을 전달 중

### 2.파일을 읽어와서 반대 방향에 Deployment 삭제 후 생성

**k8s-cicd-non-stop-deployment.yml**

```yaml
- name: Create pods using deployment
  hosts: kubernetes
  vars_files:
    - /root/sysctl_param.yml
  vars:
    color: '{{ color }}'


  tasks:
    - name: delete the previous blue deployment
      command: kubectl delete deployment.app/cicd-deployment-blue
      when: color == 'green'
      ignore_errors: yes

    - name: create a blue deployment
      command: kubectl apply -f cicd-devops-deployment-blue.yml
      when: color == 'green'

    - name: delete the previous green deployment
      command: kubectl delete deployment.app/cicd-deployment-green
      when: color == 'blue'
      ignore_errors: yes

    - name: create a green deployment
      command: kubectl apply -f cicd-devops-deployment-green.yml
      when: color == 'blue'
```
- `vars_files` 을 통해 변수가 저장된 파일을 읽어올 수 있다.
- `vars` 를 통해 변수 지정
- `when` 을 통해 조건 지정

### 3. `kubectl rollout` 명령어를 통해 Ready 상태 대기

**k8s-cicd-non-stop-service.yml**

```yaml
- name: create service for deployment
  hosts: kubernetes
  vars_files:
    - /root/sysctl_param.yml
  vars:
    color: '{{ color }}'

  tasks:
    - name: rollout blue deployment
      command: kubectl rollout status deployment cicd-deployment-blue
      when: color == 'green'

    - name: rollout green deployment
      command: kubectl rollout status deployment cicd-deployment-green
      when: color == 'blue'

    ...
```

- `kubectl rollout` 명령어를 통해 반대 방향에 생성 중인 Deployment 가 정상적으로 Ready 상태가 되었는지 확인

### 4. 파일을 읽어와서 생성된 Deployment 로 방향 변경

**k8s-cicd-non-stop-service.yml**

```yaml

    ...

    - name: patch a blue service to green service
      command: kubectl apply -f cicd-devops-blue-service.yml
      when: color == 'green'

    - name: patch a green service to blue service
      command: kubectl apply -f cicd-devops-green-service.yml
      when: color == 'blue'
```

### 5. `switch.sh` 실행하여 버전 관리 파일 변경

**switch.sh**

```shell
if [[ "$CURRENT_COLOR" ==  *blue* ]] ;
then
   $(sed -i '1s/color: blue/color: green/' /root/sysctl_param.yml)
else
   $(sed -i '1s/color: green/color: blue/' /root/sysctl_param.yml)
fi
```

---

# Kubernetes

## 서비스

`서비스 = 쿠버네티스 네트워크 / API` 

### Kubernetes Service 의 개념

Service 는 동일한 서비스를 제공하는 Pod 그룹의 단일 진입점을 제공

![image](https://user-images.githubusercontent.com/83503188/206444069-85c2eaf9-8f42-43fc-9c41-fe4a4b63cd86.png)

- Pod 들의 Label 을 기준으로 하나로 묶은 뒤 그룹에 대한 Virtual IP(단일 진입점)를 생성한다. 
- Virtual IP로 접근하면 그룹 중 하나로 연결해주는 Load Balancer 역할을 한다.
- 해당 정보를 etcd에 기록

**Service Definition**

![image](https://user-images.githubusercontent.com/83503188/206445364-e6be244a-b66c-4aff-a219-ff81512444ad.png)

- Deployment-definition 에서는 `nginx` 컨테이너에 Label(app:webui)을 붙혀서 3개 운영한다.
  - 3개의 Pod가 Worker Node 에서 동작하며 고유한 IP address를 갖는다.
- Deployment-definition 에서는 webui-svc 라는 이름으로 Service를 생성한다.
  - `clusterIP`는 보통 생략한다. -> 생략하면 랜덤한 Virtual IP 배정
  - `app: webui` Label을 가진 Pod를 묶어서 하나의 단일 진입점을 clusterIP의 80번 port로 제공한다.
  - `targetPort`는 각각 그룹에 속한 Pod들의 port 번호

> ClusterIP = VirtualIP = LoadBalancerIP

### Kubernetes Service 타입 

4가지 Type 지원
- **ClusterIP(default)**
  - Pod 그룹의 단일 진입점(Virtual IP) 생성
- **NodePort**
  - ClusterIP가 생성된 후
  - 모든 Worker Node 에 외부에서 접속가능 한 포트가 Open(예약)
  - 예를 들어 NodePort 타입의 Service 생성 시 30100번 Port 를 요구하면 그룹 Pod 들의 30100 Port 가 Open 된다.  
  - 클라이언트가 Worker Node 중 하나 30100 Port 로 연결을 요청할 시에 해당 Node 에서 그룹 Pod 중 하나로 LoadBalancing 시켜준다.    
- **LoadBalancer**
  - ClusterIP가 생성, 그룹 Pod 들에 NodePort 생성
  - 추가로 LoadBalancer 가 생성되어 클라이언트의 요청을 LoadBalancer 가 받은 뒤 그룹 Pod 중 하나로 LoadBalancing 해준다.
  - 클라우드 인프라스트럭처(AWS, Azure, GCP 등)나 오픈스택 클라우드에 적용
  - LoadBalancer 를 자동으로 프로 비전하는 기능 지원
- **ExternalName**
  - ClusterIP, LoadBalancer 서비스를 제공하는게 아닌 Naming 서비스(DNS?)를 제공한다.
  - 예를 들어 ExternalName 으로 `google.com`으로 등록하면 컨테이너 내부에서 도메인을 넣어주면 실제 도메인이 ExternalName 으로 바뀌어서 외부 통신이 가능해진다.
  - 클러스터 안에서 외부에 접속 시 사용할 도메인을 등록해서 사용
  - 클러스터 도메인이 실제 외부 도메인으로 치환되어 동작

### Kubernetes Service 사용하기

#### ClusterIP
- selector 의 label 가 동일한 Pod 들의 그룹으로 묶어 단일 진입점(Virtual IP)을 생성
- 클러스터 내부에서만 사용가능
- type 생략 시 default 값으로 `10.96.0.0/12` 범위에서 할당

**Service Example: ClusterIP**

`deploy-nginx.yaml`

```yaml
kind: Deployment
metadata:
  name: webui
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webui
  template:
    metadata:
      name: nginx-pod
      labels:
        app: webui
    spec:
      containers:
      - name: nginx-container
        image: nginx:1.14
```
- nginx-container 3개를 운영해주는 Deployment
- Label 은 `app: webui`

```text
kubectl create -f deploy-nginx.yaml
kubectl get pod -o wide
```

![image](https://user-images.githubusercontent.com/83503188/206453216-0a50ad87-0c34-4e7d-ad3a-5c95a7835209.png)

`clusterip-nginx.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
   name: clusterip-service
spec:
   type: ClusterIP
   clusterIP: 10.100.100.100
   selector:
      app: webui
   ports:
      - protocol: TCP
        port: 80
        targetPort: 80
```
- `10.100.100.100:80` 으로 접속하면 그룹 Pod 중 하나의 80 Port 로 연결

```text
kubectl create -f clusterip-nginx.yaml
kubectl describe svc clusterip-service
curl 10.100.100.100
```

![image](https://user-images.githubusercontent.com/83503188/206454191-290add22-aa0e-465b-81d7-59e5f08f0867.png)

![image](https://user-images.githubusercontent.com/83503188/206454591-d7ba5612-1117-4789-8ddb-e820d9476050.png)
- 3개의 Pod 가 묶여있음을 확인할 수 있다.

![image](https://user-images.githubusercontent.com/83503188/206454755-732b5ff0-a5f5-4f17-93fb-d6f14f0411c5.png)
- 위의 3개의 Pod 중 하나에 연결됨을 확인할 수 있다.

**ClusterIP 정리**

ClusterIP 란 단일 진입점 IP를 생성해주고 실제 동작 중인 Pod 들을 균등하게 Service 될 수 있도록 지원하는 객체

#### NodePort

- 모든 노드를 대상으로 외부 접속 가능한 포트를 예약
- Default NodePort 범위: 30000-32767
- ClusterIP 를 생성 후 NodePort 를 예약

**Service Example: NodePort**

`nodeport-nginx.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
   name: nodeport-service
spec:
   type: NodePort
   clusterIP: 10.100.100.200
   selector:
      app: webui
   ports:
   - protocol: TCP
     port: 80
     targetPort: 80
     nodePort: 30200
```
- `nodePort`를 생략 가능하다. 
  - 생략하게되면 30000-32767 중 랜덤하게 배정된다. 

```text
kubectl create -f nodeport-nginx.yaml
kubectl get service -o wide
```

![image](https://user-images.githubusercontent.com/83503188/206459325-289d441f-4309-48f0-8029-8ac7fc0a962d.png)

**결과**

![image](https://user-images.githubusercontent.com/83503188/206461721-e03314cc-2655-40f3-a21b-ed731f08de67.png)

**NodePort 정리**

ClusterIP는 내부 통신 용으로 쓴다면 NodePort 는 외부에서 접근할 수 있도록 도와준다.

#### LoadBalancer

**외부 LoadBalancer 를 세팅해달라는 요청이 LoadBalancer Type**

- Public 클라우드(AWS, Azure, GCP 등)에서 운영가능
- LoadBalancer 를 자동으로 구성 요청
- NodePort 를 예약 후 해당 NodePort 로 외부 접근을 허용

![image](https://user-images.githubusercontent.com/83503188/206466658-0101125f-3406-42ba-91c3-39dd494a77a5.png)
- NodePort 로 연결할 수 있는 외부 LoadBalancer 장비에 Setting 요청
- LoadBalancer 장비를 통해 하나의 NodePort 로 접근하면 해당 Node 에서는 그룹 Pod 중 하나로 연결해주는 구조

**Service Example: LoadBalancer**

`loadbalancer-nginx.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
   name: loadbalancer-service
spec:
   type: LoadBalancer
   selector:
      app: webui
   ports:
   - protocol: TCP
     port: 80
     targetPort: 80
```

```text
kubectl create -f loadbalancer-nginx.yaml
kubectl get service -o wide
```

![image](https://user-images.githubusercontent.com/83503188/206468378-b0617061-3526-450d-ba10-c017cbe3b555.png)

- EXTERNAL-IP 80번 Port 로 접속하면 Worker Node 중 하나의 NodePort(31572)로 접속되고 해당 Node 에서 그룹 Pod 중 하나로 연결해주는 구조이다.

#### ExternalName

- 클러스터 내부에서 External(외부)의 도메인을 설정

앞에서 배운 3가지 Type 은 전부 동작 중인 Pod 들의 단일 진입점, 외부에서 접근 가능하도록 NodePort, NodePort 를 묶어서 관리할 수 있는 LoadBalancer 장비까지 세팅해달라는 단계별 서비스(ClusterIP < NodePort < LoadBalancer)였다면 ExternalName 은 다른 성격(DNS를 지원)을 가진다.

Cluster 내부에서 외부로 나갈 수 있는 도메인을 등록해놓고 사용하는 것이다.

![image](https://user-images.githubusercontent.com/83503188/206469705-13da0eac-7f42-48b8-964a-4abae60189d1.png)
- Service 를 정의할 때 Type 을 ExternalName 으로 지정하면서 외부 도메인을 할당
- Pod 에서 `curl {Service 정의할 때 ExternalName -> google.com}-svc.default.svc.cluster.local`
- `{Service 정의할 때 ExternalName -> google.com}-svc.default.svc.cluster.local` 내용이 `google.com` 으로 치환된다.
- 앞에서 배운 Type 과는 반대되는 내용
- 쉽게 말해서 DNS 를 지원

**Service Example: ExternalName**


`externalname.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
   name: externalname-svc
spec:
   type: ExternalName
   externalName: google.com
```

```text
kubectl create -f externalname.yaml
kubectl get service -o wide

kubectl run testpod -it --image=centos:7 // 테스트를 위한 pod 생성, curl 명령어를 위한 centos
curl externalname-svc.default.svc.cluster.local
```

![image](https://user-images.githubusercontent.com/83503188/206472102-b61d6db8-04a0-4d73-9bf3-80615aae757a.png)

![image](https://user-images.githubusercontent.com/83503188/206473718-38af9470-cdde-45b2-8902-f21e0803b11a.png)


### Kubernetes 헤드리스 서비스

앞에서 설명한 Service 의 4가지 타입과는 다른 이야기

- ClusterIP 가 없는 서비스로 단일 진입점이 필요 없을 때 사용
- IP address 가 존재하지 않는 단일 진입점이 생성되고, endpoint 를 묶는 역할만 한다.
- Service 와 연결된 Pod 의 endpoint 로 DNS 레코드가 생성됨 -> kubernetes 의 coreDNS 에 레코드로 등록
- Pod 들의 endpoint 에 DNS resolving Service 받을 수 있도록 지원 가능해진다.
- Pod 의 DNS 주소: `pod-ip-addr.namespace.pod.cluster.local`

**Service Example : headless**

`headless-nginx.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
   name: headless-service
spec:
   type: ClusterIP
   clusterIP: None
   selector:
      app: webui
   ports:
   - protocol: TCP
     port: 80
     targetPort: 80
```
- `clusterIP: None`:  type 은 ClusterIP, clusterIP 는 명시적으로 None 

```text
kubectl create -f headless-nginx.yaml
kubectl get service -o wide
kubectl describe svc headless-service
```

![image](https://user-images.githubusercontent.com/83503188/206680157-61e3b80e-e627-47ae-95a9-8c831a1b5ff7.png)
- ClusterIP 가 None

![image](https://user-images.githubusercontent.com/83503188/206680467-f7f4e223-4cf0-4d01-b9fb-e33517d19be5.png)
- Pod 들이 묶여 있지만 ClusterIP 는 None


```text
kubectl run testpod -it --image=centos:7 /bin/bash # 테스트를 위한 Pod 생성
```
- `-it`: 직접 접속을 위한 옵션
- `/bin/bash`: centos:7 의 /bin/bash 바로 실행

**testPod 의 DNS 서버 확인**

![image](https://user-images.githubusercontent.com/83503188/206681466-58c42cdc-844c-4982-a322-6f16996ec288.png)
- DNS 서버: `10.96.0.10`
  - master node 가 제공해주는 coreDNS 의 IP 주소
  - 해당 주소를 통해 DNS 를 요청하게 된다.

![image](https://user-images.githubusercontent.com/83503188/206682056-6a48e7f6-f9ee-480e-a51b-91f1a6969135.png)
- Pod 의 DNS 주소(`pod-ip-addr.namespace.pod.cluster.local`) 로 DNS resolving 하게되면 실제 `10.96.0.10` Pod 에 연결시켜주는 resolving 서비스를 지원해준다.

### kube-proxy

- Kubernetes Service 의 backend 구현
- endpoint 연결을 위한 iptables 구성
- nodePort 로의 접근과 Pod 연결을 구현(iptables 구성)

`kubectl get pods --all-namespaces`

![image](https://user-images.githubusercontent.com/83503188/206683938-8d542944-b111-426b-afbf-7a4bab3df7c9.png)
- Master Node, 3 Worker Node 에 대한 kube-proxy 4개 존재
- Service 를 요청하게 되면 backend 에서 각각의 Node 에 존재하는 kube-proxy 가 동작하여 해당 Node 에 **iptables rule** 을 만들어서 클라이언트가 ClusterIP 로 접속하게되면 endpoint 중 하나로 연결해주는 구조

**Worker Node 1 iptables 확인**

![image](https://user-images.githubusercontent.com/83503188/206685377-cc2d084f-dbbf-47a1-b621-ef31ab34d1b3.png)
- `10.100.100.100` 으로 접속하게되면 위의 3 개의 IP 중 80번 포트 하나로 연결
- 이러한 rule 을 만드는 주체가 kube-proxy

kube-proxy 가 하는 역할은 크게 2가지
1. service 를 생성하게 되면 iptables rule 생성 
2. service type 을 NodePort 로 명시하면 NodePort 를 Listen 하여 클라이언트 커넥션을 잡아서 iptables rule 로 연결하여 Pod 통신을 가능하게 한다.  

#### kube-proxy mode

**userspace**
- 클라이언트의 서비스 요청을 iptables 를 거쳐 kube-proxy 가 받아서 연결
- kubernetes 초기버전에 잠깐 사용

**iptables**
- default kubernetes network mode
- kube-proxy 는 service API 요청 시 iptables rule 이 생성
- 클라이언트 연결은 kube-proxy 가 받아서 iptables 룰을 통해 연결

**IPVS**
- 리눅스 커널이 지원하는 L4 로드밸런싱 기술을 이용
- 별도의 ipvs 지원 모듈을 설정한 후 적용가능
- 지원 알고리즘: rr(round-robin), lc(least connection), dh(destination hashing), sh(source hashing), sed(shortest expected delay), nc(new queue)

