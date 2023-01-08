# Advanced Jenkins 사용 2 - SonarQube, Multi nodes

## SonarQube 사용하기

정적 분석 도구 SonarQube 와 Jenkins 연동

**SonarQube 특징**

- Continuous Integration + Analysis (지속적인 통합과 분석을 할 때 사용하는 솔루션)
  - 코드에 대한 품질을 높이기 위해서 코드가 가진 Issue, Defect, 복잡성을 분석
  - Detect Bugs & Vulnerabilities
  - Track Code Smells: 코드안에 불필요한 코드, 이상 여부를 탐지
  - 코드의 품질을 높여주는 용도로 사용

- 17 languages 지원
  - Java, C#, JavaScript, CloudFormation, Terraform, Kotlin, Ruby, Go, Scala, Flex, Python, PHP, HTML, CSS, XML, VB.NET
- CI/CD Integration
- Extensible, with 50+community plugins

**Install SonalQube**

```text
docker pull sonarqube
docker run --rm -p 9000:9000 --name sonarqube sonarqube
```


**결과**

![image](https://user-images.githubusercontent.com/83503188/203969551-2f0fb424-5121-4ad0-9968-cfa6e21b851a.png)


## SonarQube + Maven 프로젝트 사용하기

- Maven Project에 Plugin 설정 추가
  - https://docs.sonarqube.org/latest/analysis/scan/sonarqube-for-maven

![image](https://user-images.githubusercontent.com/83503188/203969460-9d39bc5e-1146-47fe-88cd-b81029385471.png)

![image](https://user-images.githubusercontent.com/83503188/203972738-387f6f93-348b-4dcc-bc39-6d5ce36a5259.png)
- SonarQube 플러그인을 추가하게되면 Maven 빌드를 통해서 SonarQube로 정보를 전달할 수 있다.

**SonarQube token 생성**
  - id: admin
  - password: admin -> admin123
  - My account -> Security -> User Token 생성

![image](https://user-images.githubusercontent.com/83503188/203970597-f30ae8f0-ee9a-4667-b509-72f89bdeeb93.png)
- 인증 정보를 위한 토큰 정보 생성
  sonar-token: squ_f37e06dc0cc6d7232e388a09f19b78c4db8f430a

**Maven build**
- mvn sonar:sonar -Dsonar.host.url=http://IP_address:9000 -Dsonar.login=[sonar-token]

![image](https://user-images.githubusercontent.com/83503188/203973277-b5843b25-d7fd-4078-a09a-0c3cbebe7903.png)

**SonarQube Projects 확인**

![image](https://user-images.githubusercontent.com/83503188/203973403-a99fce86-aca7-4777-b55c-0dce345c5c3b.png)
- 특별한 문제가 없기 때문에 passed 라고 표시


## Bad code 조사하기

- 샘플 프로젝트에 아래 코드 추가

```java
@Controller
public class WelcomeController {

    private final Logger logger = LoggerFactory.getLogger(WelcomeController.class);

    @GetMapping("/")
    public String index(Model model) {
        logger.debug("Welcome to njonecompany.com...");

        model.addAttribute("msg", getMessage());
        model.addAttribute("today", new Date());

        System.out.println("index is called by GET /");
        return "index";

    }

}
```

- 위 코드처럼 print 문장 삽입
- print 문장이 문제가 되는 부분은 아니지만 실제 운영서버에 print 문장에 의해 IO에 대한 리소스를 사용하기 때문에 프로젝트 성능을 낮춘다.

**결과**

![image](https://user-images.githubusercontent.com/83503188/203974429-37a08fc2-7849-4830-9845-b112ce89ca35.png)

![image](https://user-images.githubusercontent.com/83503188/203974535-144e878b-966e-4f16-9aab-16df967684d6.png)

- 위와 같은 결과를 표시해줌으로써 SonarQube에서 통과되지 않는 경우에 빌드 작업을 진행하지 않고 코드를 개선한 후에 다시 SonarQube에서 문제가 없는 경우에 CI/CD 작업을 진행

## Jenkins + SonarQube 연동

- Jenkins 관리 -> 플러그인 관리 -> 설치가능 -> SonarQube Scanner

- Jenkins 관리 -> Manage Credentials -> Add Credentials

![image](https://user-images.githubusercontent.com/83503188/203975734-c7928979-b0aa-4652-bccb-2106af1e9b72.png)

- Jenkins 관리 -> Configure System -> SonarQube servers

![image](https://user-images.githubusercontent.com/83503188/203976541-8751d3ba-3543-42fe-b057-d5762f6140cf.png)
- docker inspect network bridge 를 통해 ip 확인

## SonarQube 사용을 위한 Pipeline 사용하기

- My-Third-Pipeline 수정

![image](https://user-images.githubusercontent.com/83503188/203979290-26544f7c-4a6c-4c5f-a1e4-9d90321ec36f.png)

**결과**

![image](https://user-images.githubusercontent.com/83503188/203977951-f77bf916-9d75-450c-9ae3-212e5a9c414f.png)

## Jenkins Multi nodes 구성하기 - Master + Slaves

**Jenkins Master + Slaves**

![image](https://user-images.githubusercontent.com/83503188/203979963-63f70b7e-1183-4af3-b968-247db7bf5a68.png)

현재까지 Jenkins 를 단일 서버로 구성하여 사용 -> Jenkins Master

Jenkins Master 에서 사용자의 요청에 의해서 빌드, 배포하는 작업을 진행했다. 이제는 자신에게 추가된 Slave 에게 작업을 전달하여 업무를 분할


**Jenkins Slave**
- Remote에서 실행되는 Jenkins 실행 Worker Node
- Jenkins Master 의 요청 처리 -> 빌드, 배포와 같은 요청 처리
- Master로부터 전달된 Job 실행
- 다양한 운영체제에서 실행 가능
- Jenkins 프로젝트 생성 시 특정 Slave를 선택하여 실행 가능

이렇게 분할해줌으로써 Master Node 는 클라이언트의 빌드, 배포 요청을 받은 다음에 자신이 직접 처리하는게 아닌 리소스가 확보된 Slave Node 에 작업을 전달하고 결과를 받아서 처리할 수 있다.

## Jenkins Node 추가하기

**Docker Container 형태로 추가**

```text
docker run -itd --name jenkins-node1 -p 30022:22 -e container=docker --tmpfs /run --tmpfs /tmp -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /var/run/docker.sock:/var/run/docker.sock edowon0623/docker:latest /usr/sbin/init
```

**Slave Node Jdk 설치**

Jenkins Slave 에서는 Master Node 로 부터 전달받은 Job을 자신이 처리하고 결과를 반환한다. Slave Node 에서 작업을 Master 노드로 부터 전달받은 작업을 처리하기 위해서 JVM이 필요하다.

```text
yum list java*jdk-devel
yum install -y java-11-openjdk-devel.x86_64
```

**Jenkins Master Node 에서 Slave Node 로 SSH 접속하기 위한 Key 생성**

```text
ssh-keygen
ssh-copy-id root@[slave node IP]
```

**Add a slave node**

- Jenkins 관리 -> 노드 관리 -> 신규 노드

![image](https://user-images.githubusercontent.com/83503188/203985346-949597f2-100a-43f9-a023-0112f6636e11.png)

- Number of executors: 추가하고 있는 노드에서 Master 로 부터 작업(빌드, 배포 요청)을 받았을 때 동시에 처리할 수 Job의 최대 개수
- Remote root directory: 해당 경로로 빌드가 성공했을 때 workspace를 만들고 결과물을 복사한다, 없는 경우에 미리 폴더를 만들어야한다.
- Labels: 현재 사용 중인 Jenkins 프로젝트에서 다른 쪽의 프로젝트, 파이프라인이 현재 추가하는 노드를 지칭하고자 할 때 사용하는 이름
- Usage: Use this node as much as possible -> Master 가 어떠한 규칙에 의해서 Slave 를 선택할지를 결정
- Launch method: master 노드에서 slave 노드로 접속할 때 어떤 방식으로 접속할 지에 대한 정보
- Credential 추가 

![image](https://user-images.githubusercontent.com/83503188/203989243-46c3830b-6879-4370-a221-2a663c4e8200.png)

**Node 추가 결과**

![image](https://user-images.githubusercontent.com/83503188/203989563-d9ce2ee9-87d9-4eb5-830f-53ed8d817427.png)


**My-First-Project 수정**

- Restrict where this project can be run 선택
  - Label Expression: slave1
  - 해당 프로젝트가 어디에만 빌드, 배포될지를 결정

![image](https://user-images.githubusercontent.com/83503188/203989791-494eca4a-5173-45e0-adaf-cac58740d84b.png)

**빌드 결과**

![image](https://user-images.githubusercontent.com/83503188/203990101-3903c136-f818-4047-87f3-a180ad72a93f.png)

![image](https://user-images.githubusercontent.com/83503188/203990269-dbd67693-5705-4d2c-97c8-71fcfeccc69c.png)

## Jenkins Slave Node 에서 빌드하기 

Pipeline 프로젝트를 slave 노드에서 실행

**Build Stage 추가**

```yaml
pipeline {
    agent {
        label 'slave1'
    }
    tools { 
      maven 'Maven3.8.5'
    }
    stages {
        stage('github clone') {
            steps {
                git branch: 'main', url: 'https://github.com/yoon-youngjin/Construction-of-CI-CD-Pipeline-using-Jenkins.git'; 
            }
        }
        
        stage('build') {
            steps {
                sh '''
                    echo build start
                    mvn clean compile package -DskipTests=true
                '''
            }
        }
    }
}
```
- agent: slave1 Node 에 현재 pipeline을 빌드

**빌드 결과**

![image](https://user-images.githubusercontent.com/83503188/203993575-3439c4b2-1b59-486d-98f9-3ba4e10f4eb9.png)

![image](https://user-images.githubusercontent.com/83503188/203993701-25dea4ea-3203-45b6-b9eb-b7d9ed7cf096.png)


**Slave2 Node 추가**

```text
docker run --privileged --name jenkins-node2 -itd -p 40022:22 -e container=docker -v /sys/fs/cgroup:/sys/fs/cgroup --cgroupns=host edowon0623/docker:latest /usr/sbin/init
```

**앞에서 진행한 Jenkins에 Node 추가하는 작업 진행**

![image](https://user-images.githubusercontent.com/83503188/203992148-4c048181-c525-40e8-bf71-ff6343132e88.png)

**Slave2 Node에 빌드**

```yaml
pipeline {
    agent {
        label 'slave2'
    }
    tools { 
      maven 'Maven3.8.5'
    }
    stages {
        stage('github clone') {
            steps {
                git branch: 'main', url: 'https://github.com/yoon-youngjin/Construction-of-CI-CD-Pipeline-using-Jenkins.git'; 
            }
        }
        
        stage('build') {
            steps {
                sh '''
                    echo build start
                    mvn clean compile package -DskipTests=true
                '''
            }
        }
    }
}
```

**결과**

![image](https://user-images.githubusercontent.com/83503188/203994915-45b8a274-9584-4822-8ab7-0ac27bae59f2.png)
