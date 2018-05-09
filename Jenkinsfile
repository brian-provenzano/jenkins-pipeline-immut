#!groovy​
pipeline {
    agent none

    environment{
        MAJOR_VERSION = 1
        AWS_ID = credentials("AWS_ID")
        AWS_ACCESS_KEY_ID = "${env.AWS_ID_USR}"
        AWS_SECRET_ACCESS_KEY = "${env.AWS_ID_PSW}"
        //NO_BASH_HISTORY = "set +o history"
        ANSIBLE_PLAYBOOK = "../ansible/apache-playbook-aws.yml"
        PACKER_POSTPROCESS = ".././get_ami.sh"
    }

    parameters {
        booleanParam(name: 'TF_CLEANUP', defaultValue: true, 
            description: 'Cleanup the AWS resources  (TF destroy) when we are done') 
        booleanParam(name: 'AMI_CLEANUP', defaultValue: true, 
            description: 'Cleanup the AWS AMI custom images when we are done') 
        booleanParam(name: 'TF_ASG', defaultValue: false, 
            description: 'Option to setup multiple web servers in ASG/ELB')
        string(name: 'TF_CLEANUP_SLEEP', defaultValue: '300', 
            description: 'Seconds to sleep before TF destroy of all infra (if selected)')
        }

    options {
        buildDiscarder(logRotator(numToKeepStr:'5', artifactNumToKeepStr: '3'))
    }
        //TODO :
        //Build the small app/code, run tests , Create packer image configured via ansible ; pack in the new code
        //create a groovy lib/script to handle prepending no-bash-history instead of this manual env var hack
    stages{
        
         stage('Check-Update Terraform Binary'){
            agent any
            steps{
                script{
                    //TODO - update TF using get-hashicorp if requested; create a build param option and logic to check TF output if new ver avail
                    //def tfexit = sh returnStatus: true, script: 'terraform --version'
                    //echo "return code TF: ${tfexit}"
                    def tfout = sh returnStdout: true, script: 'terraform --version'
                    echo "tf output: ${tfout}"
                }
            }
        }

        stage('Init Terraform - Single Web Server (No ASG)'){
            agent any
            when {
                expression { params.TF_ASG != true }
            }
            steps{
                dir('terraform/singlewebserver'){
                    sh "terraform init -input=false -var 'aws_accesskey_uswest2=${AWS_ACCESS_KEY_ID}' -var 'aws_secretkey_uswest2=${AWS_SECRET_ACCESS_KEY}'"
                }
            }
        }

        stage('Init Terraform - ASG / ELB Web Servers'){
            agent any
            when {
                expression { params.TF_ASG == true }
            }
            steps{
                dir('terraform/asgwebserver'){
                    sh "terraform init -input=false -var 'aws_accesskey_uswest2=${AWS_ACCESS_KEY_ID}' -var 'aws_secretkey_uswest2=${AWS_SECRET_ACCESS_KEY}'"
                }
            }
        }

        stage('Create Web Server AWS AMI'){
            agent any
            steps{
                echo "Create AWS AMI using Packer"
                dir('web-images'){
                    sh 'if [ -f manifest.json ]; then rm manifest.json; fi'
                    sh "packer build -var 'postscript=${ANSIBLE_PLAYBOOK}' -var 'playbook=${ANSIBLE_PLAYBOOK}' -var 'aws_access_key=${AWS_ACCESS_KEY_ID}' -var 'aws_secret_key=${AWS_SECRET_ACCESS_KEY}' webserverAMI.json"
                    //The packer post processor script creates ami.txt to store the name of our AMI to use in later stages
                    //sh 'cat ami.txt'
                    //sh 'export NEWAMI=$(cat ami.txt | tr -d \'[:space:]\')'
                }
            }
        }

        stage('Deploy Web Server AMI -  Single Web Server (No ASG)'){
            agent any
            environment{
                NEWAMI = readFile 'ami.txt'
            }
             when {
                expression { params.TF_ASG != true }
            }
            steps{
                echo "Start Deploy Web Server AMI"
                echo "This is the AMI we are deploying from the txt file: ${env.NEWAMI}"
                //TODO: Possible make this manual sep step (possibly) for human approval..review the plan file first then apply.
                dir('terraform/singlewebserver'){
                    echo "Deploying AMI to Single Web Server (No ASG)"
                    sh "terraform plan -var 'aws_accesskey_uswest2=${AWS_ACCESS_KEY_ID}' -var 'aws_secretkey_uswest2=${AWS_SECRET_ACCESS_KEY}' -var 'key_name_uswest2=aws-uswest2-oregon-key' -var 'name=webserver' -var 'ami=${env.NEWAMI}'"
                    sh "terraform apply -auto-approve -var 'aws_accesskey_uswest2=${AWS_ACCESS_KEY_ID}' -var 'aws_secretkey_uswest2=${AWS_SECRET_ACCESS_KEY}' -var 'key_name_uswest2=aws-uswest2-oregon-key' -var 'name=webserver' -var 'ami=${env.NEWAMI}'"
                }
                //sh "terraform plan -out webserver.plan -var 'aws_accesskey_uswest2=${AWS_ACCESS_KEY_ID}' -var 'aws_secretkey_uswest2=${AWS_SECRET_ACCESS_KEY}' -var 'key_name_uswest2=aws-uswest2-oregon-key' -var 'name=webserver' -var 'ami=${env.NEWAMI}'"
                //sh "terraform apply \"webserver.plan\" -auto-approve -var 'aws_accesskey_uswest2=${AWS_ACCESS_KEY_ID}' -var 'aws_secretkey_uswest2=${AWS_SECRET_ACCESS_KEY}' -var 'key_name_uswest2=aws-uswest2-oregon-key' -var 'name=webserver' -var 'ami=${env.NEWAMI}'"
            }
        }
        
        stage('Deploy Web Server AMI - ASG / ELB Web Servers'){
            agent any
            environment{
                NEWAMI = readFile 'ami.txt'
            }
            when {
                expression { params.TF_ASG == true }
            }
            steps{
                echo "Start Deploy Web Server AMI"
                echo "This is the AMI we are deploying from the txt file: ${env.NEWAMI}"
                //TODO: Possible make this manual sep step (possibly) for human approval..review the plan file first then apply.
                dir('terraform/asgwebserver'){
                    echo "Deploying AMI to ASG / ELB Web Servers"
                    sh "terraform plan -var 'aws_accesskey_uswest2=${AWS_ACCESS_KEY_ID}' -var 'aws_secretkey_uswest2=${AWS_SECRET_ACCESS_KEY}' -var 'key_name_uswest2=aws-uswest2-oregon-key' -var 'name=webserver' -var 'ami=${env.NEWAMI}'"
                    sh "terraform apply -auto-approve -var 'aws_accesskey_uswest2=${AWS_ACCESS_KEY_ID}' -var 'aws_secretkey_uswest2=${AWS_SECRET_ACCESS_KEY}' -var 'key_name_uswest2=aws-uswest2-oregon-key' -var 'name=webserver' -var 'ami=${env.NEWAMI}'"
                }
            }
        }


        stage('Cleanup TF AWS Resources- Single Web Server (No ASG)'){
            agent any
            environment{
                NEWAMI = readFile 'ami.txt'
            }
            when {
                expression { params.TF_CLEANUP == true && params.TF_ASG != true }
            }
            steps{
                echo "Cleanup TF infra / destroy - Single Web Server (No ASG)"
                script {
                    def sleeptime = params.TF_CLEANUP_SLEEP
                    sleep sleeptime.toInteger() //sleep time before destroying infra to allow a bit of testing
                }
                dir('terraform/singlewebserver'){
                    sh "terraform destroy -auto-approve -var 'aws_accesskey_uswest2=${AWS_ACCESS_KEY_ID}' -var 'aws_secretkey_uswest2=${AWS_SECRET_ACCESS_KEY}' -var 'key_name_uswest2=aws-uswest2-oregon-key' -var 'name=webserver' -var 'ami=${env.NEWAMI}'"
                }
            }
        }

        stage('Cleanup TF AWS Resources-  ASG / ELB Web Servers'){
            agent any
            environment{
                NEWAMI = readFile 'ami.txt'
            }
            when {
                expression { params.TF_CLEANUP == true && params.TF_ASG == true }
            }
            steps{
                echo "Cleanup TF infra / destroy -  ASG / ELB Web Servers"
                script {
                    def sleeptime = params.TF_CLEANUP_SLEEP
                    sleep sleeptime.toInteger() //sleep time before destroying infra to allow a bit of testing
                }
                dir('terraform/asgwebserver'){
                    sh "terraform destroy -auto-approve -var 'aws_accesskey_uswest2=${AWS_ACCESS_KEY_ID}' -var 'aws_secretkey_uswest2=${AWS_SECRET_ACCESS_KEY}' -var 'key_name_uswest2=aws-uswest2-oregon-key' -var 'name=webserver' -var 'ami=${env.NEWAMI}'"
                }
            }
        }

        stage('Cleanup Packer AWS AMI'){
            agent any
            when {
                expression { params.AMI_CLEANUP == true && params.TF_CLEANUP == true }
            }
            steps{
                //cleanup AMI - since this is testing :  ec2-deregister,ec2-delete-snapshot 
                echo "Cleanup AMI - delete snapshot and AMI deregister - (this is lab/testing function)"
                sh "chmod +x cleanup_ami.sh"
                sh "./cleanup_ami.sh ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY} us-west-2"
            }
        }
    }
}