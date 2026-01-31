pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                // 自動抓取觸發該次建置的分支
                checkout scm
            }
        }
        
        // SonarQube 掃描
        stage('SonarQube Analysis') {
            steps {
                script {
                    // 1. 取得設定的工具路徑
                    def scannerHome = tool 'sonar-scanner'
                    
                    withSonarQubeEnv('sonarqube') {
                        sh "${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=cicd-test \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=http://172.16.1.69:9000 \
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
        
        // develop 時才執行此階段
        stage('Deploy to Dev') {
            when { branch 'develop' } 
            steps {
                echo "正在部署到開發環境..."
            }
        }

        // main 時才執行此階段
        stage('Deploy to Production') {
            when { branch 'develop' } 
            when { 
                allOf {
                    branch 'main'
                    // 甚至可以要求必須有人點擊確認
                }
            }
            steps {
                input message: "確認要發布到正式環境？"
                echo "正在部署到正式環境..."
            }
        }
        
        
    }
}