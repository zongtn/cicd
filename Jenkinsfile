pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                checkout scm // 自動抓取觸發該次建置的分支
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                // 不管哪個分支都跑掃描
                script {
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

        stage('Build & Push to Harbor') {
            steps {
                script {
                    // 定義鏡像名稱（請換成你的 Harbor 位址與專案名）
                    def remoteImage = "harbor-stage.com:8080/test/cicd-api:${env.BUILD_NUMBER}"
            
                    // 1. 使用 Harbor 憑據登入
                    withCredentials([usernamePassword(credentialsId: 'harbor-creds', passwordVariable: 'HB_PWD', usernameVariable: 'HB_USER')]) {
                        sh "docker login harbor-stage.com:8080 -u ${HB_USER} -p ${HB_PWD}"
                    }
            
                    // 2. 建置 Image
                    sh "docker build -t ${remoteImage} ."
            
                    // 3. 推送到 Harbor
                    sh "docker push ${remoteImage}"
            
                    // 4. 清理本地 Image (避免硬碟爆滿)
                    sh "docker rmi ${remoteImage}"
                }
            }
        }


        stage('Deploy to Dev') {
            // 只有當分支是 develop 時才執行此階段
            when { branch 'develop' } 
            steps {
                echo "正在部署到開發環境..."
            }
        }

        stage('Deploy to Production') {
            // 只有當分支是 main 時才執行此階段
            when { 
                expression { return env.GIT_BRANCH == 'main' || env.GIT_BRANCH == 'origin/main' || env.GIT_BRANCH == 'master' || env.GIT_BRANCH == 'origin/master' }
            }
            steps {
                input message: "確認要發布到正式環境？"
                echo "正在部署到正式環境..."
            }
        }
    }
}