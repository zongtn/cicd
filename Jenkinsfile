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
                    def harborUrl = "harbor-stage.com:8080"
                    def imageName = "${harborUrl}/test/cicd-api"
                    def tagImage = "${imageName}:${env.BUILD_NUMBER}"
                    def latestImage = "${imageName}:latest" // 新增 latest 變數

                    withCredentials([usernamePassword(credentialsId: 'harbor-creds', passwordVariable: 'HB_PWD', usernameVariable: 'HB_USER')]) {
                        sh "echo ${HB_PWD} | docker login ${harborUrl} -u ${HB_USER} --password-stdin"
                
                        // 1. 編譯並貼上兩個標籤
                        sh "docker build -t ${tagImage} -t ${latestImage} ."
                
                        // 2. 推送兩個標籤到 Harbor
                        sh "docker push ${tagImage}"
                        sh "docker push ${latestImage}"
                
                        // 3. 清理本地鏡像
                        sh "docker rmi ${tagImage} ${latestImage}"
                    }
                }
            }
        }


        stage('Deploy to Dev') {
            // 只有當分支是 develop 時才執行此階段
            when { 
                expression { return env.GIT_BRANCH == 'develop' || env.GIT_BRANCH == 'origin/develop'}
            }
            steps {
                echo "正在部署到開發環境..."
                script {
                    // 強制重啟該名稱的容器，它會自動去拉取 Harbor 最新的 latest 鏡像
                    sh "docker stop cicd-api-dev || true"
                    sh "docker rm cicd-api-dev || true"
                    sh "docker run -d --name cicd-api-dev -p 8082:80 -e ASPNETCORE_ENVIRONMENT=Development harbor-stage.com:8080/test/cicd-api:latest"
                }
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
                script {
                    // 強制重啟該名稱的容器，它會自動去拉取 Harbor 最新的 latest 鏡像
                    sh "docker stop cicd-api-prod || true"
                    sh "docker rm cicd-api-prod || true"
                    sh "docker run -d --name cicd-api-prod -p 8081:80 harbor-stage.com:8080/test/cicd-api:latest"
                }
            }
        }
    }
}