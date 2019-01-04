team: engineering-enablement
slack_channel: "#ee-pass"
pipeline: ee-app-logging-servicebroker-test

repo:
  uri: git@github.com:springernature/worlds-simplest-service-broker.git
  private_key: ((github.private_key))
  branch: test

tasks:
- type: docker-compose
  name: Build the app


- type: deploy-cf
  name: Deploy to CF Dev
  api: ((cloudfoundry.api-dev))
  space: dev
  manifest: manifest-dev.yml
  org: pe
  vars:
    AUTH_USER: ((servicebroker.user))
    AUTH_PASSWORD: ((servicebroker.password))
    CREDENTIALS: ((servicebroker.credentials))
    SYSLOG_DRAIN_URL: ((servicebroker.syslog_url_test))
