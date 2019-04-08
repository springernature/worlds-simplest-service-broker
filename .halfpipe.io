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
  parallel: true
  api: ((cloudfoundry.api-dev))
  space: dev
  manifest: manifest-dev.yml
  org: pe
  vars:
    AUTH_USER: ((servicebroker.user))
    AUTH_PASSWORD: ((servicebroker.password))
    CREDENTIALS: ((servicebroker.credentials))
    SYSLOG_DRAIN_URL: ((servicebroker.syslog_url))
    CF_API_ENDPOINT: ((servicebroker.cf_dev_api))
    CF_USER: ((servicebroker.cf_dev_user))
    CF_PASSWORD: ((servicebroker.cf_dev_password))

- type: deploy-cf
  name: Deploy to CF Dev with RTR
  parallel: true
  api: ((cloudfoundry.api-dev))
  space: dev
  manifest: manifest-dev-rtr.yml
  org: pe
  vars:
    AUTH_USER: ((servicebroker.user))
    AUTH_PASSWORD: ((servicebroker.password))
    CREDENTIALS: ((servicebroker.credentials))
    SYSLOG_DRAIN_URL: ((servicebroker.syslog_url_rtr))
    CF_API_ENDPOINT: ((servicebroker.cf_dev_api))
    CF_USER: ((servicebroker.cf_dev_user))
    CF_PASSWORD: ((servicebroker.cf_dev_password))

- type: deploy-cf
  name: Deploy test service broker to CF Dev
  parallel: true
  api: ((cloudfoundry.api-snpaas))
  space: test
  manifest: manifest-test.yml
  org: engineering-enablement
  vars:
    AUTH_USER: ((servicebroker.user))
    AUTH_PASSWORD: ((servicebroker.password))
    CREDENTIALS: ((servicebroker.credentials))
    SYSLOG_DRAIN_URL: ((servicebroker.syslog_url_test))
    CF_API_ENDPOINT: ((servicebroker.cf_snpaas_api))
    CF_USER: ((servicebroker.cf_snpaas_user))
    CF_PASSWORD: ((servicebroker.cf_snpaas_password))

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
    CF_API_ENDPOINT: ((servicebroker.cf_live_api))
    CF_USER: ((servicebroker.cf_live_user))
    CF_PASSWORD: ((servicebroker.cf_live_password))

- type: deploy-cf
  name: Deploy to CF Live with RTR enabled
  api: ((cloudfoundry.api-live))
  space: live
  manifest: manifest-rtr.yml
  org: pe
  vars:
    AUTH_USER: ((servicebroker.user))
    AUTH_PASSWORD: ((servicebroker.password))
    CREDENTIALS: ((servicebroker.credentials))
    SYSLOG_DRAIN_URL: ((servicebroker.syslog_url_rtr))
    CF_API_ENDPOINT: ((servicebroker.cf_live_api))
    CF_USER: ((servicebroker.cf_live_user))
    CF_PASSWORD: ((servicebroker.cf_live_password))
