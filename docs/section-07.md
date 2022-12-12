# 상용 클라우드 환경에 배포하기

## 배포를 위한 AWS Cloud 환경 구성하기

**AWS Cloud 실습 환경 구성도** 

![image](https://user-images.githubusercontent.com/83503188/206903270-2512c4d0-f118-456b-9a0d-483424085c6c.png)

- Jenkins 에서 빌드 후 Tomcat 서버나, Docker 서버에 배포를 진행
- Jenkins 에서 빌드한 결과물을 Ansible 에 전달하여 Tomcat 서버, Docker 서버, sonarQube 서버에 배포를 진행한다.
  - Jenkins server: 8080 port
  - Docker server: 22 port
  - Tomcat server: 8080 port
  - Ansible server: 22 port
  - SonarQube server: 9000 port

## 이미지를 이용하여 AWS EC2 생성하기

**java 가 설치된 EC2를 이미지화**  

![image](https://user-images.githubusercontent.com/83503188/206906032-bd5bc785-0489-45bc-a734-512e2da523c8.png)

![image](https://user-images.githubusercontent.com/83503188/206906082-e594aa83-569a-48c6-a9a5-516aed3ce36b.png)
- 이미지를 public 상태로 만들게되면 공유할 수 있다.
- 생성된 이미지를 통해 기본 시스템(java11, ...)이 설치된 인스턴스를 쉽게 만들 수 있다. 

**이미지를 통해 인스턴스 생성**

![image](https://user-images.githubusercontent.com/83503188/206906427-e25c23a8-d9bd-4dc2-a5e0-939eca6b0e4e.png)

![image](https://user-images.githubusercontent.com/83503188/206906632-65bfe21b-03a7-4637-a07f-32edf85c968e.png)
- 이미지에 해당하는 인스턴스의 키 페어를 선택
- 이미지에 해당하는 인스턴스의 보안 그룹을 선택
- Tomcat 서버, Docker 서버, SonarQube 서버, Ansible 서버를 위해 4개의 인스턴스 생성

![image](https://user-images.githubusercontent.com/83503188/206906775-1875a399-f273-4cdb-8074-35d91440c987.png)

![image](https://user-images.githubusercontent.com/83503188/206906881-a5fabf8c-0724-4c26-9314-933674d1a3fa.png)
- 이렇게 만든 5개의 인스턴스는 같은 네트워크에 묶여있기 때문에 동일한 VPC ID를 갖는다.
- VPC(Virtual Private Cloud)는 기존의 가상 사설 네트워크망을 구성할 때 VPN 이라는 용어를 사용하는데 AWS 에서는 사설 네트워크망을 클라우드 형태로 사용하고 있기 때문에 VPC 라고한다.
- VPC 는 가상 네트워크이기 때문에, 가상 네트워크에 묶여있는 PC 들간의 통신을 할 때 아무런 제약이 없다.
- 따라서 이제는 각 PC 통신 간에 private IP 를 통해서 통신이 가능하다.

**인스턴스 간 통신을 위한 인바운드 규칙 편집**

![image](https://user-images.githubusercontent.com/83503188/206907626-e4becbaf-fe8b-48f6-a060-b4aa59bf6297.png)
- 앞에서 설정한 보안그룹을 선택해준다.

![image](https://user-images.githubusercontent.com/83503188/206907687-deb0c6cf-0ffe-4532-8e39-05270004994a.png)
- 정상적으로 ping 테스트를 성공 

## AWS EC2에 Jenkins 서버 설치하기

**Amazon Linux 에 확장 패키지 설치**

확장 패키지를 설치하는 목적은 사용 중인 Linux 에 추가적인 Dependency 패키지를 한꺼번에 설치할 수 있다.

```text
sudo amazon-linux-extra install epel -y
```

### Maven 설치

```text
sudo amazon-linux-extra install epel -y
cd /opt
ls -ltr
sudo wget https://mirror.navercorp.com/apache/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz
sudo tar -xvf apache-maven-3.8.6-bin.tar.gz
sudo mv apache-maven-3.8.6 maven
cd maven/
```

**환경설정**

```text
vi ~/.bash_profile
source ~/.bash_profile
```
- `source` 커맨드를 통해 변경사항 적용

![image](https://user-images.githubusercontent.com/83503188/206908398-589231ca-ffd6-4c5c-882e-644b85df43ea.png)

### Git 설치

```text
sudo yum install -y git
```

### Jenkins 설치

- https://pkg.jenkins.io/redhat-stable/

```text
sudo amazon-linux-extra install epel -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install jenkins
```

**Java Jenkins 호환 문제를 해결하기 위해 Java 재설치 및 버전 변경**

```text
sudo amazon-linux-extras install java-openjdk11 
sudo /usr/sbin/alternatives --config java
```

![image](https://user-images.githubusercontent.com/83503188/206908827-dead0d3a-17c9-41f5-b8cb-9b147e3bac5f.png)

**Jenkins 실행**

```text
sudo systemctl status jenkins
sudo systemctl start jenkins
```

**Jenkins 초기 암호 확인**

```text
cat /var/lib/jenkins/secrets/initialAdminPassword
```

## AWS EC2에 Docker 서버 설치하기

### Docker 설치

```text
sudo amazon-linux-extras install epel -y
sudo yum install –y docker
```

### Docker 실행

```text
sudo usermod -aG docker ec2-user (인스턴스 재 접속)
sudo service docker start
docker run hello-world
```

## AWS EC2에 Tomcat 서버 설치하기 

```text
sudo amazon-linux-extras install epel -y
cd /opt
sudo wget https://mirror.navercorp.com/apache/tomcat/tomcat-9/v9.0.70/bin/apache-tomcat-9.0.70.tar.gz
chmod +x /opt/apache-tomcat-9.0.70.tar.gz
chmod +x bin/startup.sh
chmod +x bin/shutdown.sh
```

**Tomcat 실행**

```text
sudo /opt/apache-tomcat-9.0.70/bin/startup.sh
```

**Tomcat 제한 제거, 계정 권한 추가**

```text
sudo vi ./webapps/manager/META-INF/context.xml # 제한 제거
sudo vi ./webapps/host-manager/META-INF/context.xml # 제한 제거
sudo vi ./conf/tomcat-users.xml # 계정 권한 추가
sudo ./bin/shutdown.sh
sudo ./bin/startup.sh
```

`./webapps/manager/META-INF/context.xml`

![image](https://user-images.githubusercontent.com/83503188/207004007-3001d4de-a8e9-414e-aad3-7671d77346e7.png)
- 기존 접속 경로를 `127.x.x.x` 으로 제한된 부분을 주석처리함으로써 모든 접속을 허용

`./webapps/host-manager/META-INF/context.xml`

![image](https://user-images.githubusercontent.com/83503188/207004623-c456f8aa-da43-400e-b2af-5a7f813c521f.png)

`./conf/tomcat-users.xml`

![image](https://user-images.githubusercontent.com/83503188/207005886-2a9294cb-4892-4c0c-8680-0bfe62668271.png)

![image](https://user-images.githubusercontent.com/83503188/207006284-d6bb1b4f-c6fa-4937-95ca-b1dea88a4cf0.png)

## AWS EC2에 Ansible 서버 설치하기

```text
sudo amazon-linux-extras install epel -y
sudo yum install –y ansible
```

**hosts 파일 수정**

```text
sudo vi /etc/ansible/hosts
```

![image](https://user-images.githubusercontent.com/83503188/207007361-2c281b8f-6526-469f-a4cc-066696022da5.png)

**ssh 접속을 위한 키 복사**

```text
ssh-keygen -t rsa
```

![image](https://user-images.githubusercontent.com/83503188/207008023-3e846ef7-0174-4c91-9985-47cf57afad7f.png)

**생성된 public 키(`id_rsa.pub`)를 docker, tomcat 서버에 복사**

Ansible 서버의 public 키 복사

```text
cd ~
cat .ssh/id_rsa.pub
```

![image](https://user-images.githubusercontent.com/83503188/207008945-57da6e1b-d269-484f-8c5f-a048599b1f53.png)

Ansible 서버의 public 키 Tomcat 서버의 `.ssh/authorized_keys` 복사

![image](https://user-images.githubusercontent.com/83503188/207008756-57f4aca2-7bd4-40df-ac00-4c252016a7d7.png)

Ansible 서버의 public 키 Docker 서버의 `.ssh/authorized_keys` 복사

![image](https://user-images.githubusercontent.com/83503188/207010276-b191629e-6771-4617-ae3c-4a55bbd2ef23.png)

![image](https://user-images.githubusercontent.com/83503188/207010594-bd890bed-fdad-4b15-a7be-08b39d0b3f15.png)

**ping 테스트**

```text
ansible docker -m ping
ansible tomcat -m ping
```

![image](https://user-images.githubusercontent.com/83503188/207011840-f49ec040-d21d-4630-a51b-2486079235ad.png)

localhost 에도 마찬가지로 public 키를 복사해야한다.

## AWS EC2에 SonarQube 설치하기

SonarQube 는 앞 예제에서 사용한 ec2 t2.micro 타입인 경우에 리소스 부족으로 정상적인 서비스가 어려울 수 있기 때문에 최소 t2.small 타입으로 진행해야한다.

**EC2 인스턴스 타입 변경**

`t2.micro -> t2.small`

![image](https://user-images.githubusercontent.com/83503188/207013819-0921c184-8c0d-4b08-9010-19f7fee54aaf.png)

**SonarQube 설치**

```text
sudo amazon-linux-extras install epel -y
sudo mkdir /opt/sonarqube
cd /opt/sonarqube
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.6.zip
sudo unzip sonarqube-7.6.zip
sudo chown -R ec2-user:ec2-user /opt/sonarqube/
```
**SonarQube 설정 파일**

`/opt/sonarqube/sonarqube-7.6/conf/sonar.properties`

![image](https://user-images.githubusercontent.com/83503188/207015702-ba4c78a9-20ea-4833-8a50-7d394c590e74.png)
- default port 번호가 9000

**SonarQube 실행**

```text
cd sonarqube-7.6/
./bin/[사용하는 OS]/sonar.sh start # ./bin/linux-x86-64/sonar.sh start
```

**SonarQube 테스트**

![image](https://user-images.githubusercontent.com/83503188/207017224-c8e10e3c-1b42-44c4-ab55-f4923e55e017.png)
- 9000번 포트 open

`http://[public ip address]:9000/`

![image](https://user-images.githubusercontent.com/83503188/207017365-b20e93c1-9250-43c0-a320-1efd9d1e601e.png)
- 초기 ID: admin
- 초기 PW: admin

**Token 발급**

![image](https://user-images.githubusercontent.com/83503188/207017725-40c07235-e017-4008-9939-7d0879572470.png)

## Jenkins 를 이용하여 Tomcat 서버에 배포하기

**Maven, Deploy to Container 플러그인 설치**

**Maven 설정**

![image](https://user-images.githubusercontent.com/83503188/207018967-62ef7f2a-47b9-4396-98c6-6934c87ac4a2.png)
- `/opt/maven`: Jenkins 서버에 설치한 Maven 의 Home 디렉토리

**Project 생성 및 설정**

![image](https://user-images.githubusercontent.com/83503188/207019174-d5cecf56-3a93-4dd4-8657-83e6f6b4ab24.png)

![image](https://user-images.githubusercontent.com/83503188/207019391-ac53fa26-a28c-4a42-9dc4-5707364c2915.png)

![image](https://user-images.githubusercontent.com/83503188/207019580-e6ecd6af-6070-40f2-b66a-5c5c7b486eed.png)

![image](https://user-images.githubusercontent.com/83503188/207019488-1f9525e7-1b60-4f40-8731-20ece8c87c3e.png)

![image](https://user-images.githubusercontent.com/83503188/207019955-c554f2bf-6160-4af5-94dd-ecf3cdde15a9.png)
- Credential 생성

![image](https://user-images.githubusercontent.com/83503188/207020269-670a74c2-6507-4ff4-bf10-11a6da06ed70.png)

**결과**

`Jenkins 빌드된 결과물`

![image](https://user-images.githubusercontent.com/83503188/207021294-6ab9b00b-1de9-4240-8d4d-e484e795c4b9.png)

`Tomcat에 배포된 결과물`

![image](https://user-images.githubusercontent.com/83503188/207021375-e3fad4bd-f043-49c1-b15c-96daafab766d.png)

## Jenkins 를 이용하여 Docker 서버에 배포하기

**Jenkins 서버에서 Docker 서버로 ssh 접속을 위한 키 배포**

![image](https://user-images.githubusercontent.com/83503188/207022887-95c864c3-2d13-45f8-8542-2362b786fdec.png)
- Jenkins 서버에서 `ssh-keygen` 명령어로 생성된 public 키 복사

![image](https://user-images.githubusercontent.com/83503188/207022774-414f9da1-f6a5-45a5-99e1-c052271c2107.png)
- Docker 서버에 Jenkins 서버 public 키 붙여넣기

**publish over ssh 플러그인 설치**

**Docker 서버에 Dockerfile 생성**

```yaml
FROM tomcat:9.0

COPY ./hello-world.war /usr/local/tomcat/webapps
```

**publish over ssh 설정**

![image](https://user-images.githubusercontent.com/83503188/207024302-27a8abd8-5383-4fdf-83eb-956972cab474.png)

![image](https://user-images.githubusercontent.com/83503188/207024261-e2b3e333-4417-4bb5-b6c9-131088630921.png)

- Jenkins 서버에서 `ssh-keygen` 명령어를 통해 생성한 public 키를 Docker 서버에 복사하였고, Jenkins 서버에서 Docker 서버로 접속할 때는 private 키(`id_rsa`)를 가지고 접속을 시도하여 매칭을 통해 접속 여부를 결정한다.
- Jenkins 의 ssh 설정 정보에 private 키를 등록해야지 Docker 서버로 접속이 가능하다.

**Project 생성 및 설정**

![image](https://user-images.githubusercontent.com/83503188/207024567-8b5f27db-09d5-4333-bb49-a2158f2a4bfb.png)

![image](https://user-images.githubusercontent.com/83503188/207024616-65dff738-d48f-4fe6-9004-48c4eac9bf65.png)

![image](https://user-images.githubusercontent.com/83503188/207024648-c30659e3-8ade-4e55-a63f-de9f4fa3dc3a.png)

![image](https://user-images.githubusercontent.com/83503188/207026082-fa1308d9-f798-40b6-b4a8-43069e0a80d2.png)

**결과**

![image](https://user-images.githubusercontent.com/83503188/207025795-8ac31b8d-4926-4975-8c68-085c68431ae6.png)

![image](https://user-images.githubusercontent.com/83503188/207025977-65410d56-0d83-454d-99b9-39719d383533.png)


## Jenkins 를 이용하여 Ansible 서버에 배포하기

**Jenkins 에서 ssh 접속을 위한 Ansible 서버 등록**

![image](https://user-images.githubusercontent.com/83503188/207026948-ed83bc22-776e-49b6-8481-d4b39e533c57.png)

**Inventory 파일 & Playbook 파일 생성**

`hosts`

```text
[docker]
172.31.15.61
```

`create-cicd-devops-container.yml`

```yaml
- hosts: all
  #   become: true

  tasks:
    - name: stop current running container
      command: docker stop my_cicd_project
      ignore_errors: yes

    - name: remove stopped cotainer
      command: docker rm my_cicd_project
      ignore_errors: yes

    - name: create a container using cicd-project-ansible image
      command: docker run --privileged -d --name my_cicd_project -p 8080:8080 yoon11/cicd-project-final
```

**Project 생성 및 설정**

![image](https://user-images.githubusercontent.com/83503188/207027442-167738d9-88ed-4354-b712-15b32363780b.png)

![image](https://user-images.githubusercontent.com/83503188/207027708-824bfc6f-f603-4af0-929c-585507b6bdfe.png)

**결과**

![image](https://user-images.githubusercontent.com/83503188/207029740-c464290a-295d-46dc-b110-e7db594735ec.png)

![image](https://user-images.githubusercontent.com/83503188/207029803-96452ab0-1bfe-4de7-b916-b4d6629dcf3f.png)
