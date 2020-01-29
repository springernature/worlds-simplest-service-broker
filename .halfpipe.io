team: engineering-enablement
slack_channel: "#ee-pass"
pipeline: ee-app-logging-servicebroker-onPrem

triggers:
  - type: git

feature_toggles:
  - update-pipeline

tasks:
- type: docker-compose
  name: Build the app


- type: parallel
  tasks:
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
      CF_API_ENDPOINT: ((servicebroker.cf_dev_api))
      CF_USER: ((servicebroker.cf_dev_user))
      CF_PASSWORD: ((servicebroker.cf_dev_password))
  
  - type: deploy-cf
    name: Deploy to CF Dev with RTR
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
