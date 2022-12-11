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
sudo usermod –aG docker ec2-user (인스턴스 재 접속)
sudo service docker start
docker run hello-world
```