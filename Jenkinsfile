#!groovy​
pipeline {
    agent none

    environment{
        MAJOR_VERSION = 1
        AWS_ID = credentials("AWS_ID")
        AWS_ACCESS_KEY_ID = "${env.AWS_ID_USR}"
        AWS_SECRET_ACCESS_KEY = "${env.AWS_ID_PSW}"
    }

    parameters { 
        booleanParam(name: 'TF_CLEANUP', defaultValue: true, 
            description: 'Cleanup the AWS resources  (TF destroy) when we are done') 
        booleanParam(name: 'AMI_CLEANUP', defaultValue: true, 
            description: 'Cleanup the AWS AMI custom images when we are done') 
        string(name: 'TF_CLEANUP_SLEEP', defaultValue: '300', 
            description: 'Seconds to sleep before TF cleaup (if selected)')
        }
         

    options {
        buildDiscarder(logRotator(numToKeepStr:'5', artifactNumToKeepStr: '3'))
    }
        //TODO :
        //Build the small app/code, run tests , Create packer image configured via ansible ; pack in the new code
        //consider set +o history to avoid bash_history of secrets??
    stages{
        
         stage('Check-Update-Init Terraform'){
            agent any
                steps{
                    script{
                        def tfexit = sh returnStatus: true, script: 'terraform --version'
                        echo "return code TF: ${tfexit}"
                        def tfout = sh returnStdout: true, script: 'terraform --version'
                        echo "tf output: ${tfout}"
                    }

                    sh "terraform init -input=false -var 'aws_accesskey_uswest2=${AWS_ACCESS_KEY_ID}' -var 'aws_secretkey_uswest2=${AWS_SECRET_ACCESS_KEY}'"
                    echo "Should we TR cleanup/destroy?  ${TF_CLEANUP}"
                }
            }
        
        stage('Create Web AWS AMI'){
            agent any

            steps{
                echo "Create AWS AMI using Packer"
                sh 'if [ -f manifest.json ]; then rm manifest.json; fi'
                sh "packer build -var 'aws_access_key=${AWS_ACCESS_KEY_ID}' -var 'aws_secret_key=${AWS_SECRET_ACCESS_KEY}' webserverAMI.json"
                //this is exposed via packer in post processor - see packer json above
                sh 'cat ami.txt'
                //sh 'export NEWAMI=$(cat ami.txt | tr -d \'[:space:]\')'

            }
        }

        stage('Deploy AMI'){
            agent any

            environment{
                NEWAMI = readFile 'ami.txt'
            }

            steps{
                echo "Deploy AMI"
                echo "This is the AMI from the txt file - trimmed: "
                echo "${env.NEWAMI}"
                //sh "terraform plan -out webserver.plan -var 'aws_accesskey_uswest2=${AWS_ACCESS_KEY_ID}' -var 'aws_secretkey_uswest2=${AWS_SECRET_ACCESS_KEY}' -var 'key_name_uswest2=aws-uswest2-oregon-key' -var 'name=webserver' -var 'ami=${env.NEWAMI}'"
                sh "terraform plan -var 'aws_accesskey_uswest2=${AWS_ACCESS_KEY_ID}' -var 'aws_secretkey_uswest2=${AWS_SECRET_ACCESS_KEY}' -var 'key_name_uswest2=aws-uswest2-oregon-key' -var 'name=webserver' -var 'ami=${env.NEWAMI}'"
                //TODO: run tf apply - this should be a sep step (possibly) for human approval..something to think on
                //sh "terraform apply \"webserver.plan\" -auto-approve -var 'aws_accesskey_uswest2=${AWS_ACCESS_KEY_ID}' -var 'aws_secretkey_uswest2=${AWS_SECRET_ACCESS_KEY}' -var 'key_name_uswest2=aws-uswest2-oregon-key' -var 'name=webserver' -var 'ami=${env.NEWAMI}'"
                sh "terraform apply -auto-approve -var 'aws_accesskey_uswest2=${AWS_ACCESS_KEY_ID}' -var 'aws_secretkey_uswest2=${AWS_SECRET_ACCESS_KEY}' -var 'key_name_uswest2=aws-uswest2-oregon-key' -var 'name=webserver' -var 'ami=${env.NEWAMI}'"
                //echo "This is the AMI from the txt file - trimmed: "
                //sh 'export NEWAMI=$(cat ami.txt | tr -d \'[:space:]\')'
                //sh 'echo ${NEWAMI}'
            }
        }

        stage('Cleanup TF AWS Resources'){
            agent any
            environment{
                NEWAMI = readFile 'ami.txt'
            }
            when {
                expression { params.TF_CLEANUP == true }
            }
            steps{
                //TODO cleanup TF infra if param present; maybe... since this is testing
                echo "Cleanup TF infra / destroy - this is a lab/testing"

                script {
                    def sleeptime = params.TF_CLEANUP_SLEEP
                    sleep sleeptime.toInteger() //sleep time before destroying infra to allow a bit of testing
                }
                sh "terraform destroy -auto-approve -var 'aws_accesskey_uswest2=${AWS_ACCESS_KEY_ID}' -var 'aws_secretkey_uswest2=${AWS_SECRET_ACCESS_KEY}' -var 'key_name_uswest2=aws-uswest2-oregon-key' -var 'name=webserver' -var 'ami=${env.NEWAMI}'"
            }
        }

        stage('Cleanup Packer AWS AMI'){
            agent any
            when {
                expression { params.AMI_CLEANUP == true && params.TF_CLEANUP == true }
            }
            steps{
                //cleanup AMI created - since this is testing :  ec2-deregister,ec2-delete-snapshot 
                echo "Cleanup AMI - delete snapshot and AMI deregister - this is lab/testing"
                sh "chmod +x cleanup_ami.sh"
                //sh "./cleanup_ami.sh ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY} us-west-2"

            }
        }
    }
}