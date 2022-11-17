# DevOps와 CI/CD

## Waterfall vs. Agile

### Waterfall

![image](https://user-images.githubusercontent.com/83503188/202107635-c5c129d8-2d30-4db9-a598-5cffe93156a4.png)

**전통적인 개발 방법론**

- waterfall 방식은 프로젝트의 각 단계의 구분이 뚜렷하게 나눠져있다.
- 각 단계는 이전 단계가 완료된 후에만 진행될 수 있다.
- 폭포가 거꾸로 올라갈 수 없는 것처럼 이전 단계로 올라가기 어렵다는 단점을 가진다. 
- 따라서 고객의 니즈를 바로 반영하기가 어렵고, 반영한다고 하더라도 비용이나 시간이 크게 발생한다.
- 최근의 추세처럼 시시각각으로 변경되는 고객의 요구를 반영하기 어렵다.

### Agile

![image](https://user-images.githubusercontent.com/83503188/202108364-d85e6a4c-55e1-4090-8b08-f9b773c744b4.png)

**Waterfall 방법론과 상반적인 의미를 가지고 있는 Agile 개발 프로세스**

- Waterfall 방법론이 지나치게 계획에 의존적이고 형식적인 절차를 따르고 있기 때문에 시간도 오래걸리고 효율성이 크게 저하된다는 단점을 Agile 방법론에서는 이러한 부분을 최소화한다.
- Agile 방법론은 기존의 소프트웨어 개발 방법에 있어서 아무런 계획이 없었던 개발 방법, 지나치게 계획이 많았던 개발 방법 사이에서 타협점

**Manifesto for Agile Software Development**
1. **개인과 상호작용**을 process and tool 보다 우선시 
2. **작동하는 소프트웨어**를 comprehensive documentation 보다 우선시
3. **고객과의 협력**을 contract negotiation 보다 우선시
4. **변화에 대응**을 following a plan 보다 우선시 

## Cloud Native Application 의 구성요소

**Cloud Native Application**: Cloud Native Architecture 에 의해서 설계되고 구현되는 어플리케이션

- 크게 4가지 형태로 구성 
- 시스템이 견고하고 다양한 요구사항, 예기치 못한 예외 사항이 발생한다 하더라도 형태, 구조가 깨지지 않아야 한다.

![image](https://user-images.githubusercontent.com/83503188/202111365-b06a0992-6b58-4391-89fc-c10ae7472b29.png)

1. Microservices -> 마이크로서비스로 개발된다.
2. Containers -> 어플리케이션을 구성하고 있는 마이크로서비스들을 클라우드 환경에 배포하고 사용하기 위해 컨테이너 가상화 기술이 표준처럼 사용
3. DevOps -> 서비스에 문제가 생기거나 사용자의 니즈를 바로바로 수정하고 반영하고 다시 배포하기 위해서 개발과 운영조직간의 유기적인 협력을 통해 지속적인 서비스 개선 방법
4. CI/CD -> 마이크로서비스들을 CI/CD 자동화 파이프라인을 통해서 자동으로 통합, 빌드, 테스트 배포과정을 통해 운영상태가 된다.

### Cloud Native - MSA

![image](https://user-images.githubusercontent.com/83503188/189047408-76029868-0dac-4566-b33a-5365f6025b4b.png)

- inner Architecture: 단순한 도메인을 가지고, 비즈니스 로직을 가지고 서비스를 개발하는 쪽
- outer Architecture: inner architecture 로 구성된 어플리케이션들이 운영하고 작동될 수 있도록 supported system

앞 강의에서 Spring Boot 와 Spring Cloud 로 개발된 결과물을 빌드해서 배포하는데 있어서 CI CD 파이프라인을 구현할 계획

### Cloud Native - Containerization

![image](https://user-images.githubusercontent.com/83503188/202119703-de2790d1-adae-47d3-9a9f-9ce2618fb819.png)

마이크로서비스 어플리케이션으로 개발된 결과물은 컨테이너 기반의 가상화에 의해서 실행되는 경우가 많다.

수많은 마이크로서비스 어플레케이션이 가상화 방식이 아니라 실제 서버를 통해 기동되면 리소스의 낭비뿐만 아니라 많은 비용을 발생시킬 수 있다.

또한 유지보수, 요구되는 민첩성에 대해서도 불리하다. 

- 컨테이너 가상화는 기존의 물리적인 서버를 운영하는 것처럼 사용되는 서버 가상화에 비해서 적은 리소스를 사용한다.
- 공유할 수 있는 부분에 대해서는 각각의 컨테이너 가상화 인스턴스들이 레이어로 구분되어 있는 상태로 공유해줌으로써 최소한의 리소스를 통해서 애플리케이션, 미들웨어, 운영체제를 구동할 수 있게된다.
- 컨테이너 가상화의 대표적인 제품이 도커

### Cloud Native - DevOps

![image](https://user-images.githubusercontent.com/83503188/202120279-f3727d36-1c0a-4451-a6f6-99580eeeca0a.png)

**Development + Operation**

개발과 운영 조직을 단일화하여 개발에서 운영에 이르기까지 필요한 프로세스를 단순화하고 고객으로부터의 피드백, 요청사항, 시스템 변화에 신속하게 대응하기 위한 개발 프로세스

![image](https://user-images.githubusercontent.com/83503188/202120803-80201cb9-664c-4d33-bf23-f345df1a168f.png)

- 엔지니어가 프로그래밍하고, 빌드하고, 직접 시스템에 배포 및 서비스를 RUN
- 사용자와 끊임 없이 Interaction 하면서 서비스를 개선해 나가는 일련의 과정, 문화

### Cloud Native - CI/CD

개발자 및 팀에 의해서 개발된 결과물을 지속적인 통합과 지속적인 배포를 하는 프로세스

CI/CD는 개발된 애플리케이션을 통합하고 빌드, 배포에 이르기까지 전 과정에 대해서 자동화 처리를 담당하게 된다.

- CI(Continuous Integration): 작업된 코드의 컴파일, 테스트, 패키징하는 작업
- CD(Continuous Delivery, Continuous Deployment): CI에 의해 패키징된 작업물을 다시 개발, 테스트, 운영 서버로 배포하는 작업
  - Continuous Delivery: CI 에서 통합된 데이터를 검증하고 최종 배포를 수동으로 하는 작업
  - Continuous Deployment: 자동으로 전 과정을 배포하는 작업

![image](https://user-images.githubusercontent.com/83503188/202125568-1667ca67-7f3e-481a-87b7-ef49435c9864.png)

- MSA 는 하나의 단일 애플리케이션이 아닌 애플리케이션을 구성하고 있는 서비스들을 서로 독립적인 형태로 개발하고 배포하는 아키텍처
- 이렇게 개발된 서비스는 하나의 단일 서버에 통합되어 운영되기 보다는 물리적으로 또는 논리적으로 분리되어 있는 상태의 분산된 서버에 각각 실행    
- 따라서 개발하는 서비스의 개수만큼 서버가 필요한 경우가 많은데, 이렇게 수많은 서버에 배포하는 과정이 단순화, 자동화되어 있지 않으면 상당한 시간을 할애해야한다.

#### CI/CD Flow

![image](https://user-images.githubusercontent.com/83503188/189051911-52a43b49-8765-46b4-8796-620a9bd10658.png)

- CI 도구로써 Jenkins를 사용한다.
- Jenkins를 통해서 빌드하고 배포하려는 애플리케이션 자체가 Spring Boot, Spring Cloud로 개발된 형태이기 때문에 코드를 빌드하기 위한 도구로써 maven을 사용한다.
- 빌드된 결과물을 운영서버에 배포한다.
- 운영하려는 서버는 컨테이너 가상화 형태로 운영될 것이기 때문에 컨테이너 런타임 중 하나인 Docker를 사용한다.
- 이러한 Docker 컨테이너들의 배포 관리, 시스템 관리를 위해서 Orchestration 도구인 k8s를 사용한다.
- Jenkins와 k8s 사이의 IaC인 Ansible을 통해서 서버에 인프라스트럭처 관리를 스크립트 형태로 관리하기 위한 시스템

**최종 결과물**

![image](https://user-images.githubusercontent.com/83503188/202130174-755b1eb8-9a62-4b7e-a53d-ccd0a720eaf5.png)

### Jenkins

지속적인 통합과 배포라는 의미를 가진 CI/CD 작업에 있어서 시스템의 자동화 파이프라인 또는 Work flow 를 설계하는데 사용되는 도구

프로젝트 자동화 배포에 있어서 주로 CI 부분에 많이 사용되고 있으나 CD에 대한 부분에 있어서도 Jenkins를 사용할 계획이다.

- Jenkins에서는 작업의 단위는 Item, 각각의 단계를 하나의 아이템으로 구성해서 수행할 수도 있고, 여러 아이템을 하나로 묶어서 pipeline 을 구성하여 작업할 수도 있다.
- Jenkins만의 유일한 문법 체계인 DSL(Domain Specific Languages)을 이용하여 파이프라인 스크립트를 만들 수 있고 파이프라인 스크립트는 'Jenkinsfile' 이라는 이름을 가져야한다.
- DSL(Domain Specific Language): 도메인에 특화된 언어 -> ex.) DockerFile, JenkinsFile

### Jenkins 설치 및 설정

![image](https://user-images.githubusercontent.com/83503188/189105343-a0cdf771-795f-4d9e-aa82-17ef86a86703.png)
- {계정}/{레포지토리} : jenkins/jenkins -> jenkins 계정의 jenkins 레퍼지토리

**이미지 다운로드**

`docker pull jenkins/jenkins`

**Jenkins 실행**

`docker run -d -p 8080:8080 -p 50000:50000 --name jenkins-server --restart=on-failure jenkins/jenkins:lts-jdk11`

- run: docker 에서 이미지 생성 커맨드
- -p: 퍼블리셔 옵션, 컨테이너 내부의 포트를 컨테이너 밖 환경에서 어떻게 접속할지 결정 -> -p 8080:8080: 컨테이너 밖 8080 포트를 사용하면 컨테이너 내부 8080으로 접속
- --restart=on-failure: on-failire 상태가 되면 restart하는 옵션
- -v: 볼륨 옵션, docker 실행 환경(window, mac)에서 어떠한 디렉토리하고 도커 내부의 디렉토리하고 mount(연결)할지 결정 -> jenkins_home:/var/jenkins_home
- --name: 컨테이너에 이름부여, 옵션없는 경우 random name 적용
- -d: detach 모드, 현재 실행 터미널과 분리하여 실행, 백그라운드 형태로 실행

![image](https://user-images.githubusercontent.com/83503188/189107621-bfb02c4d-392f-4669-9835-9dfe041530a0.png)

- 0:0:0:0:8080 -> 어떤 요청이든 8080으로 들어오면 도커의 8080포트로 연결

![image](https://user-images.githubusercontent.com/83503188/189113944-f74f8920-aba2-4a12-89b1-3ab47b28e6df.png)

**Docker 컨테이너에 터널링으로 접속**

`docker exec -it jenkins-server bash`