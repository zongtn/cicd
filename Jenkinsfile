pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                // 從 GitHub 拉取程式碼
                checkout scm
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                script {
                    // 1. 取得剛剛在 Tools 設定的工具路徑
                    def scannerHome = tool 'sonar-scanner'
                    
                    // 2. 使用環境變數注入，不要把 Token 寫死在代碼中
                    withSonarQubeEnv('sonarqube') { 
                        // 注意：如果 Jenkins 跑在 Docker 裡，localhost 會指向 Jenkins 自己。
                        // 請將下面的 IP 改為你機器的真實內網 IP (例如 192.168.x.x)
                        sh "${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=cicd-test \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=http://http://172.16.1.69:9000 \
                        -Dsonar.login=${SONAR_AUTH_TOKEN}"
                    }
                }
            }
        }
        
        // 可選：如果你希望掃描不及格就停止 pipeline
        stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
    }
}