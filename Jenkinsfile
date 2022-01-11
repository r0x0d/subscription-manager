pipeline {
  agent { label 'subman' }
  options {
    timeout(time: 15, unit: 'MINUTES')
  }
  environment {
    REGISTRY_URL = 'quay.io/candlepin'
    GIT_HASH = sh(returnStdout: true, script: "git rev-parse HEAD").trim()
    PODMAN_USERNS = 'keep-id'
  }
  stages {
    stage('Build Container') {
      environment {
        QUAY_CREDS = credentials('candlepin-quay-bot')
      }
      steps {
        sh './containers/build_and_push.sh'
      }
    }
    stage('Test') {
      parallel {
        stage('stylish') {
          agent { label 'subman' }
          steps {
            sh('sh ./jenkins/run.sh stylish jenkins/stylish.sh')
          }
        }
        stage('tito') {
          steps {
            sh('sh ./jenkins/run.sh tito jenkins/tito.sh')
          }
        }
        // TODO: figure if this is needed and implement
        // stage('RHEL8 unit') {steps {echo 'nose'}}
        stage('unit') {
          steps {
            sh('sh ./jenkins/run.sh unit jenkins/unit.sh')
            junit('coverage.xml')
            // TODO: find the correct adapter or generate coverage tests that can be
            //       parsed by an existing adapter:
            //       https://plugins.jenkins.io/code-coverage-api/
            // publishCoverage adapters: [jacocoAdapter('coverage.xml')]
          }
        }
        // Unit tests of libdnf plugins
        stage('libdnf') {
          steps {
            sh('sh ./jenkins/run.sh libdnf jenkins/libdnf.sh')
          }
        }
      }
    }
  }
}
