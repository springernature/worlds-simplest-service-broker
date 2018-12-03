team: engineering-enablement
slack_channel: "#ee-pass"
pipeline: ee-app-logging-servicebroker-onPrem

repo:
  uri: git@github.com:springernature/worlds-simplest-service-broker.git
  private_key: ((github.private_key))
  branch: pipeline

tasks:
- type: docker-compose
  name: Clone the OSS service broker from SpringerPE

- type: deploy-cf
  name: Deploy to CF GCP
  api: ((cloudfoundry.api-live))
  space: test
  manifest: manifest.yml
  org: pe
