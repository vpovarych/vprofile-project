pipeline {
    agent any
    
    environment {
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "10.128.0.35:8081"
        NEXUS_REPOSITORY = "vprofile-release"
        NEXUS_REPOGRP_ID = "vprofile-grp-repo"
        NEXUS_CREDENTIAL_ID = "nexuslogin"
        ARTVERSION = "${env.BUILD_ID}"
    }
    
    stages {
        stage('BUILD') {
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

        stage('UNIT TEST') {
            steps {
                sh 'mvn test'
            }
        }

        stage('INTEGRATION TEST') {
            steps {
                sh 'mvn verify -DskipUnitTests'
            }
        }
        
        stage('CODE ANALYSIS WITH CHECKSTYLE') {
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
            post {
                success {
                    echo 'Generated Analysis Result'
                }
            }
        }

        stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
                    // true = set pipeline to UNSTABLE, false = don't
                    echo TESTTTT
                }
            }
        }
        
        stage('Publish to Nexus Repository Manager') {
            steps {
                script {
                    // Извлекаем метаданные через Maven в shell (полный обход песочницы Sandbox)
                    def projectVersion = sh(script: 'mvn help:evaluate -Dexpression=project.version -q -DforceStdout', returnStdout: true).trim()
                    def projectGroupId = sh(script: 'mvn help:evaluate -Dexpression=project.groupId -q -DforceStdout', returnStdout: true).trim()
                    def projectArtifactId = sh(script: 'mvn help:evaluate -Dexpression=project.artifactId -q -DforceStdout', returnStdout: true).trim()
                    def projectPackaging = sh(script: 'mvn help:evaluate -Dexpression=project.packaging -q -DforceStdout', returnStdout: true).trim() ?: 'jar'
                    
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
