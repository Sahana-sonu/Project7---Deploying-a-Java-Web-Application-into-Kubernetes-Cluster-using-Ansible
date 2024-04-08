pipeline {
    agent any
    
    stages {

        stage('CODE CHECKOUT') {
            steps {
                git branch: 'main', url: 'https://github.com/Sahana-sonu/Project7---Deploying-a-Java-Web-Application-into-Kubernetes-Cluster-using-Ansible.git'
            }
        }
        
        stage('MODIFIED IMAGE TAG') {
            steps {
                
                sh '''
                   sed "s/image-name:latest/$JOB_NAME:v1.$BUILD_ID/g" playbooks/dep_svc.yml
                   sed -i "s/image-name:latest/$JOB_NAME:v1.$BUILD_ID/g" playbooks/dep_svc.yml
                   sed -i "s/IMAGE_NAME/$JOB_NAME:v1.$BUILD_ID/g" webapp/src/main/webapp/index.jsp
                   '''
            }            
        }
        
        stage('BUILD') {
            steps {
                sh 'mvn clean install package'
            }
        }
        
   stage('Static Code Analysis') {
      environment {
        SONAR_URL = "http://52.167.200.192:9000/"
      }
      steps {
        withCredentials([string(credentialsId: 'sonarqube', variable: 'SONAR_AUTH_TOKEN')]) {
          sh 'mvn sonar:sonar -Dsonar.login=$SONAR_AUTH_TOKEN -Dsonar.host.url=${SONAR_URL}'
        }
      }
    }
        stage('COPY JAR & DOCKERFILE') {
            steps {
                
             
               sh 'ansible-playbook playbooks/create_directory.yml -i hosts'
              // sh 'ansible-playbook playbooks/create_directory.yml -i inventory --extra-vars "ansible_ssh_common_args=\'-o StrictHostKeyChecking=no\'"'
                
            }
        }
        
        stage('PUSH IMAGE ON DOCKERHUB') {
            environment {
            dockerhub_user = credentials('dockerhub_user')            
            dockerhub_pass = credentials('dockerhub_pass')
            }    
            steps {
                
                sh 'ansible-playbook playbooks/push_dockerhub.yml -i hosts \
                    --extra-vars "JOB_NAME=$JOB_NAME" \
                    --extra-vars "BUILD_ID=$BUILD_ID" \
                    --extra-vars "dockerhub_user=$dockerhub_user" \
                    --extra-vars "dockerhub_pass=$dockerhub_pass" \
                    --become'              
            }
        }
        
        stage('DEPLOYMENT ON K8S') {
            steps {
                sh 'ansible-playbook playbooks/create_pod_on_eks.yml -i hosts\
                    --extra-vars "JOB_NAME=$JOB_NAME"'
            }            
        }
        
    }
}
