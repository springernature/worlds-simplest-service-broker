team: engineering-enablement
slack_channel: "#ee-pass"
pipeline: ee-app-logging-servicebroker-onPrem

repo:
  uri: git@github.com:springernature/worlds-simplest-service-broker.git
  private_key: ((github.private_key))

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
    SYSLOG_DRAIN_URL: ((servicebroker.syslog_url))

- type: deploy-cf
  name: Deploy to CF Live
  api: ((cloudfoundry.api-live))
  space: live
  manifest: manifest.yml
  org: pe
  vars:
    AUTH_USER: ((servicebroker.user))
    AUTH_PASSWORD: ((servicebroker.password))
    CREDENTIALS: ((servicebroker.credentials))
    SYSLOG_DRAIN_URL: ((servicebroker.syslog_url))
