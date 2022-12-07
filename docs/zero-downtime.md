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