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
                // 'sonarqube' 必須對應你 image_053656.png 裡的 Name 欄位
                withSonarQubeEnv('sonarqube') {
                    // 如果你沒安裝 scanner 插件到環境變數，可以使用 tool 語法
                    // sh 'sonar-scanner -Dsonar.projectKey=cicd-test'
                    
                    // 這是最通用的掃描指令
                    // 專案 Key 必須對應你在 SonarQube 建立的名稱 (cicd-test)
                    sh """
                        sonar-scanner \
                        -Dsonar.projectKey=cicd-test \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=${SONAR_HOST_URL} \
                        -Dsonar.login=${SONAR_AUTH_TOKEN}
                    """
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