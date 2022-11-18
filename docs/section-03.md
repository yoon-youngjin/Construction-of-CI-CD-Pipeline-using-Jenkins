# Jenkins + Infrastructure as Code(IaC) 와의 연동

## Infrastructure as Code 개요와 Ansible의 이해

### IaC
- 프로비저닝 도구 
- 이름 그대로 코드에 의해서 코드에 의해서 Infrastructure 를 관리한다. -> 생성, 네트워크 설정, 삭제, ...
- 시스템, 하드웨어 또는 인터페이스의 구성정보를 파일(스크립트)을 통해 관리 및 프로비저닝
- IT 인프라스트럭처, 베어 메탈 서버(하드웨어에 어떠한 소프트웨어도 설치되어있지 않은 순수한 하드웨어) 등의 물리 장비 및 가상 머신과 관련된 구성 리소스를 관리 -> 운영체제, 네트워크 설정, 미들웨어설치 관리
- 버전 관리를 통한 리소스 관리 
- Ansible, Terraform, CHEF, AWS Cloud Formation, puppet, ...
- Ansible 은 기존에 이미 구성되어 있는 서버들의 정보 변경이나 설정들을 원하는 형태로 바꾸는데 특화되어 있는 IaC 도구
- Ansible 은 다른 IaC 대비해서 가볍고 빠르게 원하는 작업을 할 수 있다는 장점을 가진다.
- Ansible 은 구성관리 도구라고 불리기 때문에 시스템을 교체하는 작업도 가능하지만 그러한 작업보다는 문제점을 해결하는 용도(어떤 문제가 발생했을 때 복구하는 방법을 스크립트로 기록)로 사용한다.
- Terraform 은 Infrastructure 를 구축하는데 주로 사용되고, Ansible 은 구축된 서버들의 구성정보를 변경하거나 관리하는데 주로 사용된다.   

Infrastructure 를 관리함에 있어서 버전 관리가 가능한 스크립트 형태로 작업을 하게되면 프로그래밍이 가능해지므로 일정 부분을 자동화 시킬 수 있다.

### Before & After Configure management

**Before**

구성정보 파일을 다루는데 있어서 IaC를 사용하지 않았을 때

![image](https://user-images.githubusercontent.com/83503188/202630581-dcfb6794-f51c-437a-9981-9f61fac57bdf.png)

- 서버가 4대가 존재하고, 다양한 형태의 디바이스를 통해 서버를 관리
- 특정 서버에 오류가 생겨서 관리자가 알게되면 오류 생긴 서버를 지우고 필요한 서버를 증설하여 정상적인 서비스를 지원

**After**

위 작업을 하는데 있어서 IaC를 사용했을 때 

![image](https://user-images.githubusercontent.com/83503188/202631110-2fb113fc-4d14-4c3b-857a-112013983bf1.png)

- Ansible 에 서버들을 관리하도록 지정 -> inventory
- 서버를 관리함에 있어서 서버의 목록이나 작업 절차를 담아둔 스크립트 파일을 지정 -> Play Books


![image](https://user-images.githubusercontent.com/83503188/202630867-1489454a-d21c-47a4-82b9-f77749c0b3e4.png)

![image](https://user-images.githubusercontent.com/83503188/202631604-53422d72-6f0c-46e3-b170-085661a1490c.png)

- 서버 한대가 문제가 생긴다면 Play Books에 기록된 정보에 의해서 자동으로 새로운 서버를 추가하는 작업을 통해 정상적인 서비스를 지원
- 이와 같이 관리자가 직접해야하는 인프라의 제어나 관리를 Ansible, Terraform 과 같은 IaC 도구를 통해 대신 관리 가능
- 이와 같이 새롭게 추가된 서버는 Ansible 을 통해서 지속적으로 상태를 유지할 수 있도록 지원해준다. 

### Configuration Management Tools

![image](https://user-images.githubusercontent.com/83503188/202631888-a12ef548-ffe9-4e57-920a-236810e6f89f.png)

- Ansible 의 가장 큰 핵심은 Agent가 불필요하다는 부분
- 대부분 메인 서버(Ansible 서버)가 운영 서버(클라이언트)를 관리하는데 있어서 운영 서버(클라이언트)들은 메인 서버(Ansible 서버)로 부터 정보를 전달 받기 위한 Agent(클라이언트) 들이 필요한 부분이 대부분이고 이러한 Agent(클라이언트)와 메인 서버(Ansible 서버) 사이의 프로토콜 통해 통신을 해서 작업을 주고 받는다.
- Ansible 을 사용하면 운영 서버(클라이언트) 이러한 Agent 가 필요없다.
- 이유는 각각의 서버에 Python 언어가 설치되어 있다면 Python이 가진 네트워크 모듈을 통해서 서버와 통신하기 때문이다. -> 리눅스 시스템은 기본적으로 Python이 설치되어 있다.


### Ansible
- 여러 개의 서버를 효율적으로 관리할 수 있게 해주는 환경 구성 자동화 도구
  - Configuration Management, Deployment & Orchestration tool
  - IT infrastructure 자동화
- Push 기반 서비스
- Simple, Agentless(별도로 관리하고자하는 대상 서버에 추가로 설치할 내용이 포함되어있지 않다.)
- 할 수 있는일
  - 설치: apt-get, yum, homebrew
  - 파일 및 스크립트 배포: copy
  - 다운로드: get_url, git
  - 실행: shell, task
  - 즉, Ansible 서버에서 대상 서버가 되는 곳에 프로그램을 설치, 파일 및 스크립트 배포, 다운로드, 실행이 가능하다.
- 결과
  - ok / failed / /changed / unreachable

Ansible을 통해 관리하고자하는 대상 서버들에게 Push 형태로 데이터를 전달해주게된다. 푸시형식으로 데이터를 전달할 때는 Ansible과 관리 대상서버 사이에 통신은 SSH 프로토콜에 의해 이뤄지므로 별도의 Agent가 필요없다는 것이다.

앞 실습에서 이미지를 푸시하고, 컨테이너를 생성하는 과정에서 처음에는 문제가 없었으나 두번째 컨테이너를 실행하는데 문제가 생김
왜냐하면 도커 컨테이너를 기동함에 있어서 같은 이름, 같은 포트의 컨테이너에 대한 문제가 존재

기존에 기동되고 있는 서비스가 존재하는 경우에 Jenkins에서 해당 서비스를 다시 배포하는게 안되는 것은 아니다.
현재 Ansible을 통한 작업은 기존에 작업되어 있었던 컨테이너를 중지하거나 여러번 실행한다고 하더라도 지속적으로 해당 작업이 반응할 수 있도록 한다.
Ansible을 통해서 하고싶은 작업은 기존의 도커에서 기동중이던 컨테이너를 중지하고 다시 기동하거나 이미지를 다시 배포하는 용도 -> Configuration Management, Deployment

#### 구성도 예시 

![image](https://user-images.githubusercontent.com/83503188/202634774-8ffd038d-9257-418d-804b-8b6eb7491435.png)

### Install Ansible
- Ansible Server 설치 (Linux)
  - `yum install ansible`
  - `ansible --version`
- 환경 설정 파일 -> `/etc/ansible/ansible.cfg`
- Ansible 에서 접속하는 호스트 목록 -> `/etc/ansible/hosts`
  ![image](https://user-images.githubusercontent.com/83503188/202635083-81cf5674-34bf-4b13-946e-64eb2c22526d.png)
  - nginx 라는 그룹의 목록들  

## Docker 컨테이너로 Ansible 실행하기 

- Ansible 을 가지고 있는 도커 이미지 -> edowon0623/ansible
  - password: P@ssw0rd

### Run Ansible Server

**실행**

```text
docker run -itd --name ansible-server -p 20022:22 -p 8081:8080 -e container=docker --tmpfs /run --tmpfs /tmp -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /var/run/docker.sock:/var/run/docker.sock edowon0623/ansible:latest /usr/sbin/initin/init
docker run --privileged --name ansible-server -itd -p 20022:22 -p 8081:8080 -e container=docker -v /sys/fs/cgroup:/sys/fs/cgroup edowon0623/ansible:latest /usr/sbin/init
```
- --privileged: 관리자 권한을 가지고 실행


**Docker network 상세보기**

```text
docker network inspect bridge
```

![image](https://user-images.githubusercontent.com/83503188/189519202-9a5143c4-68c0-4566-b37c-8e29437a55cc.png)

**ssh 접속**
```text
ssh root@localhost -p 20022
```
- 호스트PC에 접속할 때 포트포워딩 (-p 20022) 접속하게되면 도커엔진에 연결된 ansible 서버로 접속가능

**inventory**

- `vi /etc/ansible/hosts`
  - ansible이 클라이언트로 관리하고자 하는 대상을 정리한 파일

**ssh-keygen**

Ansible 서버에서 등록한 대상 서버들로 ssh를 통해 접속하는데 있어서 root, password 를 통해 접속하는데,
Ansible 을 통해서 실행하려는 커맨드가 매번 아이디와 패스워드를 입력하기 번거롭기 때문에 Ansible 서버에 존재하는데 키값을 가지고 대상 서버에 배포함으로써 아이디, 패스워드없이 접속하게한다.

- `ssh-keygen`
  - /root/.ssh/id_rsa (id_rsa: 퍼블릭, 프라이빗 키) 생성
- `ssh-copy-id root@172.17.0.2`
  - 키 값을 배포하여 접속시 아이디, 비밀번호 생략 가능

### Ansible 설정과 작동 과정

- ansible-server: 172.17.0.3
- docker-server: 172.17.0.4

**inventory 생성**

```text
mkdir /etc/ansible
vi /etc/ansible/hosts
```

**/etc/ansible/hosts**

```text
[devops]
172.17.0.3
172.17.0.4
```
- ansible-server 자기 자신도 클라이언트로 관리
- docker-server 클라이언트로 관리

**현재상황 (java 제외)**

![image](https://user-images.githubusercontent.com/83503188/189519556-3dbbbbba-0e00-456b-8f2e-c6b509806e69.png)
![image](https://user-images.githubusercontent.com/83503188/189519635-29cb24e7-f16d-47b2-891f-804a590e08c6.png)
- Ansible 서버 안에서 다른 서버로 접속할 때는 포트포워딩 X 

![image](https://user-images.githubusercontent.com/83503188/189519650-e3651f53-a12d-4bbf-af3f-76d95b67a6df.png)
- ssh-keygen, ssh-copy-id를 통해 매번 아이디, 패스워드를 전달하지 않고 접속할 수 있도록 변경

**keygen 전**

![image](https://user-images.githubusercontent.com/83503188/189519781-f879c631-5b4e-4ad4-afb8-b747c0429afd.png)

**keygen 후**

```text
ssh-copy-id root@172.17.0.3
ssh-copy-id root@172.17.0.4
```

![image](https://user-images.githubusercontent.com/83503188/189519823-89fab1e3-93c6-4032-94ab-e8898bfc5574.png)

## Ansible 기본 명령어

### Test Ansible module
- 실행 옵션
  - -i(--inventory-file) 
    - 적용 될 호스트들에 대한 파일 정보
    - 적용되고자 하는 Ansible 클라이언트들에 대한 정보를 지정할 수 있다
    - -i 옵션이 없을 경우에는 `etc/ansible/hosts` 내용을 사용
  - -m 
    - 모듈 선택
  - -k 
    - 관리자 암호 요청
    - ssh-copy-id를 통해 이미 처리 -> 암호 필요 X
  - -K 
    - 관리자 권한 상승
  - --list-hosts 
    - 적용되는 호스트 목록

**멱등성**
- 같은 설정을 여러 번 적용하더라도 결과가 달라지지 않는 성질
  - ex) echo -e "[mygroup]\n172.20.10.11" >> /etc/ansible/hosts
  - 예를 들어 echo 커맨드를 이용해서 문자열을 해당 파일에 저장한다고 하면 Ansible 를 통해서 실행하면 한 번만 동작한다.

**멱등성 X**

![image](https://user-images.githubusercontent.com/83503188/202647717-cca1a87c-977d-457e-804a-bd403109bfa1.png)

## Ansible 묘듈 사용

**Ansible Test**

```text
ansible all -m ping 
ansible devops -m ping
```
- all: ansible에 적용 시키고자하는 그룹의 이름 
  - all의 경우에 모든 그룹
- -m
  - 모듈선택
  - ping: 모듈 이름

**결과**

![image](https://user-images.githubusercontent.com/83503188/202648840-1b279e98-a5df-4450-b0f1-83539d8f1c1e.png)

**Disk 용량 확인**

```text
ansible devops -m shell -a "free -h" 
```
- devops 그룹에 shell 명령어를 통해 free -h 전달

**파일 전송**

```text
ansible devops -m copy -a "src=./test.txt dest=/tmp"
```

**프로그램 설치**
- 특정 프로그램 설치 확인: yum list installed | grep httpd

```text
ansible devops -m yum -a "name=httpd state=present"
```

## Ansible Playbook 사용하기

Ansible Playbook: 사용자가 원하는 내용을 미리 작성해 놓은 파일
- ex) 설치, 파일 전송, 서비스 재시작, ...
- ex) 다수의 서버에 반복 작업을 처리하는 경우

- Playbook
  - vi first-playbook.yml
  - 실행: ansible-playbook first-playbook.yml

![image](https://user-images.githubusercontent.com/83503188/189520689-f489b2e8-03c6-4fe3-8ae1-e92c29cc2215.png)

- name -> 만들고자하는 Playbook 이름
- hosts -> 적용하고자하는 그룹의 이름 or IP address
- tasks -> 해당 타겟에 적용시킬 내용
  - blockinfile: 파일에 block을 만들어서 특정 내용을 추가
  - path: 적용 위치
  - block: `|` 필수, /etc/ansible/hosts 위치에 두 줄 추가  

**playbook 실행**

```text
ansible-playbook first-playbook.yml
```

**결과**

![image](https://user-images.githubusercontent.com/83503188/189520908-e8a0f1cc-6287-4e75-8870-ddf1333a71ca.png)

- 멱등성에 의해서 똑같은 명령어를 실행해도 결과가 변경되지 않는다.

![image](https://user-images.githubusercontent.com/83503188/202652003-0a229d04-8735-4e03-95ae-3bfc782d00ef.png)


### Ansible Playbook

**Ansible Playbook 예제 - 파일 복사**

```yaml
- name: Ansible Copy Example Local to Remote
  hosts: devops
  tasks:
    - name: copying file with playbook
      copy:
        src: ~/sample.txt
        dest: /tmp
        owner: root
        mode: 0644
```

![image](https://user-images.githubusercontent.com/83503188/189521191-f582b48d-1d98-42b9-9d9b-73d9b93e8898.png)

- 결과

![image](https://user-images.githubusercontent.com/83503188/202652997-9b631da0-93f2-481c-afa2-ee42e9113e8e.png)

**Ansible Playbook 예제 - 다운로드**

```yaml

---
- name: Download Tomcat9 from tomcat.apache.org
  hosts: all
  #become: yes
  # become_user: root
  tasks:
   - name: Create a Directory /opt/tomcat9
     file:
       path: /opt/tomcat9
       state: directory
       mode: 0755
   - name: Download the Tomcat checksum
     get_url:
       url: https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.69/bin/apache-tomcat-9.0.69.tar.gz.sha512
       dest: /opt/tomcat9/apache-tomcat-9.0.69.tar.gz.sha512
   - name: Register the checksum value
     shell: cat /opt/tomcat9/apache-tomcat-9.0.69.tar.gz.sha512 | grep apache-tomcat-9.0.69.tar.gz | awk '{ print $1 }'
     register: tomcat_checksum_value
   - name: Download Tomcat using get_url
     get_url:
       url: https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.69/bin/apache-tomcat-9.0.69.tar.gz
       dest: /opt/tomcat9
       mode: 0755
       checksum: sha512:{{ tomcat_checksum_value.stdout }}"
```

- 4개의 Job
  1. /opt/tomcat9 폴더 생성
  2. get_url 명령어를 통해 Tomcat Checksum 다운로드
  3. Checksum 등록
  4. get_url 명령어를 통해 실제 Tomcat 다운로드

![image](https://user-images.githubusercontent.com/83503188/189522061-eaf9c715-2d45-46db-a355-7b7aea349cad.png)

## Jenkins + Ansible 연동하기 

지금부터는 Ansible과 Ansible playbook을 이용해서 Jenkins에서 활용하는 방법

컨테이너 중복 문제를 Ansible을 통해 해결

### Setup Ansible on Jenkins

- Manage Jenkins -> Configure System -> Publish on SSH

![image](https://user-images.githubusercontent.com/83503188/202656432-0a2c26ce-7f76-4fe3-a967-249a3e7bd006.png)

Port 는 현재 Jenkins 서버에서 Ansible 서버로 ssh 접속이므로 20022가 아닌 22를 통해 접속

## Jenkins + Ansible Playbook 사용하기

**Maven project- My-Ansible-Project**

**Post-Build Actions**

![image](https://user-images.githubusercontent.com/83503188/202657166-d6f2b376-f71c-45b0-bd6c-c6b7785b6b1c.png)
- Jenkins에서 생성한 war 파일을 Ansible 서버에 복사

- 결과

![image](https://user-images.githubusercontent.com/83503188/202661157-06359e28-e877-4c18-91cf-35b2d89451d1.png)

**first-devops-playbook.yml**

```yml
- hosts: all
#   become: true  

  tasks:
  - name: build a docker image with deployed war file
    command: docker build -t cicd-project-ansible .
    args: 
        chdir: /root
```

- task -> war 파일을 통해 image 생성
  - args: chdir -> 작업 할 대상 : /root 디렉토리 -> default 위치인 /etc/ansible/hosts가 아닌 직접 inventory를 명시하는 방법

**hosts**

```text
172.17.0.3
```

**playbook 실행**

```text
ansible-playbook -i hosts first-devops-playbook.yml
```

![image](https://user-images.githubusercontent.com/83503188/189524001-1daf6f99-eb27-4304-9c36-087c21485145.png)

위의 작업을 이제 Jenkins 에서 커맨드를 통해 실행

![image](https://user-images.githubusercontent.com/83503188/202664280-7a00c391-0942-48fa-b879-aaa8f3b171b4.png)


**생성한 이미지를 컨테이너로 만드는 작업까지 추가**

```yml
- hosts: all
#   become: true

  tasks:
  - name: build a docker image with deployed war file
    command: docker build -t cicd-project-ansible .
    args:
        chdir: /root
  - name: create a container using cicd-project-ansible image
    command: docker run --privileged -d --name my_cicd_project -p 8080:8080 cicd-project-ansible
```

![image](https://user-images.githubusercontent.com/83503188/189524335-03fdeb4d-0976-480b-b8a1-8577877d17d9.png)


### 기존 컨테이너 중지 삭제 작업 추가

**second-devops-playbook.yml**

```yml
- hosts: all
#   become: true

  tasks:
  - name: stop current running container
    command: docker stop my_cicd_project
    ignore_errors: yes

  - name: remove stopped cotainer
    command: docker rm my_cicd_project
    ignore_errors: yes

  - name: remove current docker image
    command: docker rmi edowon0623/cicd-project-ansible
    ignore_errors: yes

  - name: build a docker image with deployed war file
    command: docker build -t cicd-project-ansible .
    args:
        chdir: /root
  - name: create a container using cicd-project-ansible image
    command: docker run --privileged -d --name my_cicd_project -p 8080:8080 cicd-project-ansible
```
- name: stop current running container
  - 작동 중인 컨테이너가 있다면 stop
  - 작동 중인 컨테이너가 없다면 exception이 발생할 수 있기 때문에 ignore_errors: yes를 통해 무시
- name: remove stopped cotainer
  - 중지된 컨테이너를 삭제 
- name: remove current docker image
  - 이미지 삭제
- name: build a docker image with deployed war file
  - 이미지 새로 빌드
- name: create a container using cicd-project-ansible image
  - 이미지를 통해 컨테이너 새로 생성 후 기동

![image](https://user-images.githubusercontent.com/83503188/202666434-98bcdca7-92ae-4ade-8331-556b49ef4e24.png)

## Ansible을 이용한 Docker 이미지 관리

**테스트했던 도커이미지를 hub 사이트에 업로드**
```
docker push yoon11/cicd-project-ansible
```

**위 작업을 playbook에 추가 - create-cicd-devops-image.yml**

```yml
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
- name: create a docker image with deployed waf file
  - 이미지 생성
- name: push the image on Docker Hub
  - 이미지 푸시
- name: remove the docker image from the ansible server
  - 기존 이미지 삭제

**컨테이너 생성해주는 playbook - create-cicd-devops-container.yml**

ansible-server, docker-server 에 모두 적용

```yml
- hosts: all
#   become: true

  tasks:
  - name: stop current running container
    command: docker stop my_cicd_project
    ignore_errors: yes

  - name: remove stopped cotainer
    command: docker rm my_cicd_project
    ignore_errors: yes

  - name: remove current docker image
    command: docker rmi yoon11/cicd-project-ansible
    ignore_errors: yes

  - name: pull the newest image from Docker hub
    command: docker pull yoon11/cicd-project-ansible

  - name: create a container using cicd-project-ansible image
    command: docker run --privileged -d --name my_cicd_project -p 8080:8080 yoon11/cicd-project-ansible
```

- 이미지 삭제 -> Hub에서 이미지를 pull -> 컨테이너 생성

**change the hosts file**

```text
172.17.0.3
172.17.0.4
```
- docker-server IP 추가 

여기서 문제는 두 서버에서 동일하게 이미지 생성 -> 컨테이너 생성이 이뤄지면, 이미지가 굳이 2번 생성되어 허브 사이트에 2번 push 되는 것은 좋지 못하다.

```text
ansible-playbook -i hosts create-cicd-devops-image.yml --limit 172.17.0.3 : ansible 서버에만 한정
ansible-playbook -i hosts create-cicd-devops-container.yml --limit 172.17.0.4 : 도커 서버에만 적용
```
- limit 옵션을 통해서 image를 생성하여 hub에 푸시하는 playbook은 특정 IP에서만 한정할 수 있다.


**태그 부착**
```text
docker tag cicd-project-ansible yoon11/cicd-project-ansible
```
![image](https://user-images.githubusercontent.com/83503188/189525475-db307481-283d-433d-ad57-6451b12d5565.png)

**Hub 로그인**

![image](https://user-images.githubusercontent.com/83503188/189525515-6c0b93ee-c18d-4dd6-8417-ec65189f7ba0.png)

**Hub 푸시**

![image](https://user-images.githubusercontent.com/83503188/189525539-7e326ddd-0574-4774-85b1-e3d958a0bf38.png)
![image](https://user-images.githubusercontent.com/83503188/189525568-07558212-eeac-4b17-bd4e-d350932aa9ad.png)

ansible 서버에서 docker 서버로 배포작업

host 추가

```
172.17.0.3
172.17.0.4
```

**결과**

![image](https://user-images.githubusercontent.com/83503188/189526826-9535f4af-1b88-45b2-a5c3-fed0441530a4.png)

- 현재 도커서버에는 이미지와 컨테이너가 존재하지 않기때문에 무시, pull과 컨테이너 생성은 성공

## Ansible Playbook으로 Docker 컨테이너 생성

**Jenkins 명령어 추가**

![image](https://user-images.githubusercontent.com/83503188/202685404-35da92ba-8f16-4ef2-a840-e34f7b40677d.png)

