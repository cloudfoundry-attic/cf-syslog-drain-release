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

### Configuring Scalable Syslog Opt-in

By default, scalable syslog services all syslog drain bindings. It is possible
to configure scalable syslog as opt-in only. To do so, first deploy the system
with the `scalablesyslog.scheduler.require_opt_in` property to `true` within
the `scheduler` job.

Users can then opt to use scalable syslog by appending a `drain-version=2.0`
query parameter to their syslog drain URL when creating a user provided
service. Scalable syslog will ignore bindings without the query parameter.

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
[scalable-syslog]:     https://code.cloudfoundry.org/scalable-syslog
[cf-deployment]:       https://github.com/cloudfoundry/cf-deployment
[sample-manifest]:     https://code.cloudfoundry.org/scalable-syslog-release/blob/master/manifests/scalable-syslog.yml
[common-cloud-config]: https://github.com/cloudfoundry/bosh-deployment/blob/master/warden/cloud-config.yml
