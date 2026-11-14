pipeline {
    
	agent any
/*	
	tools {
        maven "maven3"
    }
*/	
    environment {
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "10.128.0.35:8081"
        NEXUS_REPOSITORY = "vprofile-release"
	    NEXUS_REPOGRP_ID    = "vprofile-grp-repo"
        NEXUS_CREDENTIAL_ID = "nexuslogin"
        ARTVERSION = "${env.BUILD_ID}"
    }
	
    stages{
        
        stage('BUILD'){
            steps {
                sh 'mvn clean install -DskipTests'
            }
            post {
                success {
                    echo 'Now Archiving......'
                    archiveArtifacts artifacts: '**/target/*.war'
                }
            }
        }

	stage('UNIT TEST'){
            steps {
                sh 'mvn test'
            }
        }

	stage('INTEGRATION TEST'){
            steps {
                sh 'mvn verify -DskipUnitTests'
            }
        }
		
        stage ('CODE ANALYSIS WITH CHECKSTYLE'){
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
            post {
                success {
                    echo 'Generated Analysis Result'
                }
            }
        }

        stage("Publish to Nexus Repository Manager") {
            steps {
                script {
         		 	// Читаем pom.xml стандартными средствами без внешних плагинов
      		      	def pomContent = readFile('pom.xml')
         		  	def pom = new XmlSlurper().parseText(pomContent)
            	    def projectVersion = pom.version.text()
            		def projectGroupId = pom.groupId.text() ?: pom.parent.groupId.text()
            		def projectArtifactId = pom.artifactId.text()
            		def projectPackaging = pom.packaging.text() ?: 'jar'
                    def filesByGlob = findFiles(glob: "target/*.${projectPackaging}")
            		echo "${filesByGlob[0].name} ${filesByGlob[0].path}"
         		    def artifactPath = filesByGlob[0].path
            
         		    if(fileExists(artifactPath)) {
         		        echo "*** File: ${artifactPath}, group: ${projectGroupId}, packaging: ${projectPackaging}, version ${projectVersion}"
           			 	nexusArtifactUploader(
                    	nexusVersion: NEXUS_VERSION,
                    	protocol: NEXUS_PROTOCOL,
                    	nexusUrl: NEXUS_URL,
                    	groupId: NEXUS_REPOGRP_ID,
                    	version: ARTVERSION,
                    	repository: NEXUS_REPOSITORY,
                    	credentialsId: NEXUS_CREDENTIAL_ID,
                    	artifacts: [
                     	    [artifactId: projectArtifactId,
                   		    classifier: '',
                      	  	file: artifactPath,
                        	type: projectPackaging],
                        	[artifactId: projectArtifactId,
                        	classifier: '',
                        	file: "pom.xml",
                      		type: "pom"]
                    	]
              		  );
          		  } else {
            	    error "*** File: ${artifactPath}, could not be found";
                    }
                }
            }
        }


    }


}
