# Scalable Syslog Release

This is a [Bosh](https://bosh.io) release of [scalable syslog](https://github.com/cloudfoundry-incubator/scalable-syslog).

### Deploying Scalable Syslog (standalone)

The release is built to be deployed independently. It can also be used as a composite release within [cf-deployment](https://github.com/cloudfoundry/cf-deployment). The following steps are for deploying it independently.

The provided [manifest](https://github.com/cloudfoundry-incubator/scalable-syslog-release/blob/master/manifests/scalable-syslog.yml) is setup to use the [common cloud config](https://github.com/cloudfoundry/bosh-deployment/blob/master/warden/cloud-config.yml).

Example deploying to bosh-lite.

```bash
bosh -e lite update-cloud-config $HOME/workspace/bosh-deployment/warden/cloud-config.yml
cd $HOME/workspace/scalable-syslog-release
bosh -e lite upload-release https://bosh.io/d/github.com/cloudfoundry-incubator/consul-release
bosh create-release && bosh -e lite upload-release --rebase
bosh -e lite -d scalablesyslog deploy manifests/scalable-syslog.yml --vars-store=/tmp/bosh-lite-ss.yml
```
