# Scalable Syslog Release

This is a [Bosh][bosh] release of [scalable syslog][scalable-syslog].

### Deploying Scalable Syslog (standalone)

The release is built to be deployed independently.
It can also be used as a
composite release within
[cf-deployment][cf-deployment].
The following steps are for deploying it independently.

The provided
[manifest][sample-manifest]
is setup to use the
[common cloud config][common-cloud-config].

Example deploying to bosh-lite.

```bash
bosh -e lite upload-release https://bosh.io/d/github.com/cloudfoundry-incubator/consul-release
bosh -e lite update-cloud-config $HOME/workspace/bosh-deployment/warden/cloud-config.yml
cd $HOME/workspace/scalable-syslog-release
bosh create-release --force
bosh -e lite upload-release --rebase
bosh -e lite -d scalablesyslog deploy manifests/scalable-syslog.yml -o manifests/fake-ops.yml --vars-store=/tmp/bosh-lite-ss.yml
```

### Generating Certificates

To deploy the scalable syslog,
you will need three sets of certificates for
the following connections:

1. the scheduler to Cloud Controller,
2. the scheduler to the adapters, and
3. the adapters to the reverse log proxies (i.e., loggregator).

To generate these certs,
you will need the CA used within Loggregator,
as well as the CA used to sign the Cloud Controller certificate.
This is typically the diego BBS CA.

Assuming you have these two CAs,
run the following commands:

```
./scripts/generate-certs bbs-ca.crt bbs-ca.key loggregator-ca.crt loggregator-ca.key
```

[bosh]:                https://bosh.io
[scalable-syslog]:     https://github.com/cloudfoundry-incubator/scalable-syslog
[cf-deployment]:       https://github.com/cloudfoundry/cf-deployment
[sample-manifest]:     https://github.com/cloudfoundry-incubator/scalable-syslog-release/blob/master/manifests/scalable-syslog.yml
[common-cloud-config]: https://github.com/cloudfoundry/bosh-deployment/blob/master/warden/cloud-config.yml
