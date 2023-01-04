# Jenkins를 이용한 CI/CD 자동화 도구의 사용

## CI/CD를 위한 Git, Maven 설정

### Setup Maven Plugin
- Manage Jenkins -> 플러그인 관리 -> 설치 가능 -> maven

![image](https://user-images.githubusercontent.com/83503188/202388735-412c3a91-826a-4d2b-81e5-8d1672c354cb.png)

- Manage Jenkins -> Global Tool Configuration -> maven

![image](https://user-images.githubusercontent.com/83503188/202389923-5901f3dc-7e1c-4093-a8e4-a0fc74837ffc.png)

### 간단한 실습

**Maven project - My-Second-Project**

![image](https://user-images.githubusercontent.com/83503188/202390275-d354435b-1522-4e15-b4b3-79a813fe95c7.png)

**소스 코드 관리**

![image](https://user-images.githubusercontent.com/83503188/189310346-9d8175e3-34f7-46c4-9048-c1e02a2e4cd9.png)

- 소스 코드 가져올 레포지토리 명시

**Build**

![image](https://user-images.githubusercontent.com/83503188/189310540-95b6d839-33a3-4e26-9ba3-2386948afea1.png)

- maven 프로젝트이므로 maven 빌드 툴로 컴파일
- Root POM: pom.xml 
  - maven 관련 설정파일 기반으로 빌드
- Golds: clean compile package 
  - clean: 이전 빌드 삭제
  - compile: 컴파일
  - package: 컴파일된 내용을 가지고 pom.xml 파일에 지정된 옵션을 따라서 package 파일 생성

최종적으로 build 성공 후 workspace에 build 결과물(webapp/target/xxx) 생성 -> webapp.war

![image](https://user-images.githubusercontent.com/83503188/189312206-b0410cc3-281e-410b-8ab1-cb8201699f79.png)

![image](https://user-images.githubusercontent.com/83503188/189312623-3d76f322-a33d-4c1b-8df0-3e5d239e108e.png)

![image](https://user-images.githubusercontent.com/83503188/189313795-2c39dd25-bc6a-4995-9e16-bf132901f1a5.png)

## CI/CD 작업을 위한 Tomcat 서버 연동

### Setup Tomcat Plugin

- Manage Jenkins -> 플러그인 관리 -> 설치 가능 -> deploy to container plugin

### 간단한 실습

**Maven project - My-Third-Project**

Build까지는 Second-Project와 동일

![image](https://user-images.githubusercontent.com/83503188/202394794-d68a0c39-d8a7-4f39-9547-c479a54877d6.png)

**Post-build Actions (빌드 후 조치)**

- Deploy war/ear to a container: 패키징된 파일을 컨테이너에 배포
- `**/*.war`: 현재 디렉토리 하위 파일 중 확장자가 war 

![image](https://user-images.githubusercontent.com/83503188/189316419-26e72089-725c-4069-a157-072829d3f5fe.png)

**Add Container**

어떠한 컨테이너에 배포할지

![image](https://user-images.githubusercontent.com/83503188/189316736-04236c11-1d48-4236-8c84-688a97e47b38.png)
- Tomcat URL 문제 발생! 아래에서 설명

**Credentials**

톰캣 서버에 war 파일을 배포하기 위해서는 톰캣 서버에 접근할 수 있는 (Deploy 할 수 있는) 권한이 있어야 한다.

![image](https://user-images.githubusercontent.com/83503188/189316350-ef577903-6341-40b6-8075-c78ebb41ef79.png)

**결과**

![image](https://user-images.githubusercontent.com/83503188/202401656-2668485b-accd-4af4-b7b5-ed71f5436cab.png)

![image](https://user-images.githubusercontent.com/83503188/202401156-6b1591ad-6427-4a11-92c4-5afc38ac7df6.png)
- window에서 기동 중인 Tomcat > webapps 에 war 파일이 복사되었다.

**Tomcat URL**

현재 Jenkins는 도커로 기동 중이며 외장 Tomcat은 로컬PC로 기동 중이다.

![image](https://user-images.githubusercontent.com/83503188/189321798-4579bc82-92db-498d-ada2-ae06f538f293.png)

- 127.0.0.1:8088로 작성한다면 도커내부의 8088을 찾으려고 시도하고 없으므로 오류가 발생하게된다.
- 따라서 127.0.0.1 or localhost가 아닌 windows IP를 작성해줘야한다.



## PollSCM 설정을 통한 지속적인 파일 업데이트

### Setup PollSCM 

- Project > Configure > Build Triggers(빌드 유발)
  - Build periodically -> cron job : 코드에 변경사항이 없어도 일단 빌드
  - Poll SCM -> cron job : 업데이트를 할 때 커밋에 대한 내용이 있는 경우에만 빌드

![image](https://user-images.githubusercontent.com/83503188/189326497-bb3992d0-08dc-4e42-9c5f-f6af5a7c0303.png)

![image](https://user-images.githubusercontent.com/83503188/189327225-c96dc832-5672-4e9e-9932-f00dc3be9e00.png)

**결과 - 깃에 푸시함과 동시에 자동 배포**

![image](https://user-images.githubusercontent.com/83503188/189327358-1375a4de-a3ce-48aa-885c-dd1ea3eadd10.png)

## SSH + Docker가 설치되어 있는 VM(컨테이너) 사용하기

Jenkins에서 만들어진 결과인 패키징된 파일을 다른 서버에 복사, 현재까지 로컬시스템의 Tomcat에 복사하는 작업을 했음

### Setup Publish Over Plugin

- Manage Jenkins -> 플러그인 관리 -> 설치 가능 -> Publish over SSH
- Manage Jenkins -> Configure System -> Publish over SSH

![image](https://user-images.githubusercontent.com/83503188/189329144-7b247fe3-6760-47cd-8d54-ce9114d14073.png)

- 현재까지는 Jenkins에서 만들어진 결과물(hello-world.war)를 로컬의 Tomcat에 복사하였다.
- 이제는 다른 서버에 결과물파일을 복사해서 사용할 것이다.
- 따라서 로컬시스템 외에 다른 서버가 필요하다. 그래서 도커에 가상의 서버를 설치하여 사용할 것이다.
- 새롭게 추가되는 Docker의 가상 서버 Container 에는 SSH, 도커 엔진이 포함된다.
- 새롭게 설치된 VM(컨테이너)안에 도커 엔진을 설치
- Jenkins에서 만들어진 war파일을 ssh 통해 서버에 복사

![image](https://user-images.githubusercontent.com/83503188/189329765-612d38a5-7f8c-4ee7-8919-7ed8739ade4d.png)

- 단, 도커에서 사용해야하므로 이미지로 만들어주는 작업이 있어야한다.
  - 참고로 도커에서 말하는 이미지란 실행하고자 하는 내용이 포함된 단일화된 결과물
- 도커에서 이미지로 만들기 위해서는 DokcerFile이 필요하다. 쉽게말해 war파일 + DockerFile = 이미지
- 이미지는 Tomcat서버와 복사된 war파일을 포함되어있을 것이다.

![image](https://user-images.githubusercontent.com/83503188/189330342-5356e640-906c-4414-bf7f-c0c29b2c64c3.png)

**Jenkins에서 해야할 작업**

1. 결과파일(war)을 SSH 를 이용해서 복사 (서버2)
2. 서버2번에서 DockerFile + *.war 를 이용하여 Docker Image 생성(빌드)
3. Docker Image 를 가지고 컨테이너를 생성

script 에 1,2,3 작업을 포함시켜야한다.

**Docker Server 와 SSH 가 설치된 Docker Image pull**

```text
docker pull edowon0623/docker:latest
```

**Windows, MacOS intel chip) SSH 서버 (with 도커) 실행 명령어**

```text
docker run --privileged --name docker-server -itd -p 10022:22 -p 8081:8080 -e container=docker -v /sys/fs/cgroup:/sys/fs/cgroup edowon0623/docker:latest /usr/sbin/init
```

**SSH 접속**
```text
ssh root@localhost -p 10022
```

**Docker 실행을 위한 설정 변경**

```text
$ vi /etc/sysconfig/docker -> 필요 X 
$ yum install -y iptables net-tools
$ sed -i -e 's/overlay2/vfs/g' /etc/sysconfig/docker-storage
$ systemctl start docker
```

### 간단한 실습

**Maven project - My-Docker-Project**

![image](https://user-images.githubusercontent.com/83503188/202444659-7ae07852-d21e-4550-b21a-4625dc527629.png)

**Post-build Actions**

- Send build artifacts over SSH

![image](https://user-images.githubusercontent.com/83503188/189342397-74f26b36-10f6-427a-978a-7badfb355239.png)

![image](https://user-images.githubusercontent.com/83503188/189342485-54574af0-7076-44c9-bf92-6b53d9efa9a9.png)

**이미지 빌드 명령어 (Container 내에서 테스트)**

```text
docker build --tag docker-server -f Dockerfile .
```

**컨테이너 실행 명령어 (Container 내에서 테스트)**

```text
docker run --privileged  -p 8080:8080 --name mytomcat docker-server:latest
```

![image](https://user-images.githubusercontent.com/83503188/189343757-98fd5543-e1b1-475f-b5fd-b3dfcaf9e676.png)

**결과**

![image](https://user-images.githubusercontent.com/83503188/202450588-12987633-9e03-45af-8059-4556df00e957.png)
- Docker in Docker 방식이 아닌 외부 EC2를 통해 처리

### 위의 수동적인 과정을 Jenkins를 통해 처리

**Post Build Actions**

![image](https://user-images.githubusercontent.com/83503188/189349487-f2bca555-8fa5-4de4-aeed-f0f7f1f7e32e.png)

```text
docker build --tag=cicd-project -f Dockerfile .
docker images 
docker image inspect cicd-project:latest
docker run -p 8080:8080 --name mytomcat cicd-project:latest
```

- 빌드가 성공하면 이미지가 생성되고 컨테이너가 생성

**결과**

![image](https://user-images.githubusercontent.com/83503188/202451796-86870bb9-81d7-419a-804a-caf2459dee3c.png)


**남은문제**

- 컨테이너가 작동 중인 상태에서 빌드 시 실패
- 같은 이름으로 두개의 컨테이너를 실행할 수 없기 때문
- 수작업후 다시 작동시키면 성공

위와 같은 문제를 자동화하기 위해 IaC를 사용




