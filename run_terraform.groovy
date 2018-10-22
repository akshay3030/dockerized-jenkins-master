/* DevOps CI/CD Pipeline Terraform Jenkins Handler
 *
 * akshay.dce@gmail.com
 */

pipeline {
    agent {
        node {
            label params.SLAVE_LABEL
        }
    }

    stages {
        stage ('Run-Terraform') {
        
            environment {
                IMAGE_NAME = "hashicorp/terraform:${terraform_version}"
                GIT_UNIQUE = GIT_URL.replace(".git","").split("/")
                GIT_KEY = "${GIT_UNIQUE[-2]}/${GIT_UNIQUE[-1]}"
            }
            
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS_ID}",accessKeyVariable: 'AWS_ACCESS_KEY_ID',secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']])
                   {
                      println("TERRAFORM_ACTION ----> ${TERRAFORM_ACTION} & AWS CredentialsID: ${AWS_CREDENTIALS_ID}") 
                      sh "curl -O -L https://s3-us-west-2.amazonaws.com/em-devops-terraform/utilities/terraform_runtime_handler ; chmod +x terraform_runtime_handler"
                            
                      sh("./terraform_runtime_handler -e ${ENVIRONMENT} -i ${IMAGE_NAME} -t ${TERRAFORM_ROOT} -a ${TERRAFORM_ACTION} --terraform-init-args ${TERRAFORM_INIT_ARGS} --terraform-other-args ${TERRAFORM_OTHER_ARGS} --statefile-s3-key ${GIT_KEY}/${TERRAFORM_ROOT}/${ENVIRONMENT}")
                      //--backend-type ${BACKEND_TYPE} additonal option for managing your own terraform backed e.g. s3-cloud(default) or own
                   }
            }

        }
    }

    post {
        always {
            cleanWs()
        }
    }

}
