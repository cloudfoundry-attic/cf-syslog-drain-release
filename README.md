# Scalable Syslog Release

Scalable syslog is a [Bosh][bosh] release that works in conjunction with
[Loggregator](https://github.com/cloudfoundry/loggregator) to bind 
applications to syslog readers. It can be independently scalable to 
support large numbers of 
[User Provided syslog drains](https://docs.cloudfoundry.org/devguide/services/log-management.html).

The [Loggregator Design Notes](https://github.com/cloudfoundry/loggregator/docs/loggregator-design.md) presents an
overview of Loggregator components and architecture.
### Configuring Scalable Syslog Components
The scalable syslog release contains three components.

#### Scheduler 
This component handles communication with the Cloud Controller to receive new bindings
it does not need to be scaled beyond a single instance.

#### Reverse Log Proxy (RLP)
This component scales in conjunction with your overall log volume. We recommend no less than 2 instances for High Availability and 1/2 your number of Traffic Controllers. (This is actually a component of the [Loggregator release](https://github.com/cloudfoundry/loggregator).

#### Syslog Adapter
This component manages the connections to drains. They should be scaled with the number of drains.
A general rule of thumb is to plan for no less than 2 instances and 1 additional instance 
for every 500 drain bindings or adapters are reporting dropped. 

### Operator Metrics
The following new metrics are being emitted.

`loggregator.rlp.ingress` - ingress into reverse log proxy
`loggregatopr.rlp.egress` - egress out of reverse log proxy
`scalablesyslog.adapter.ingress` - ingress into adapters (these are tagged by index and drain protocol)
`scalablesyslog.adapter.engress` - engress out of adapters (these are tagged by index and drain protocol)
`scalablesyslog.adapter.dropped` - dropped messages on adapters (these are tagged by index and drain protocol)
`scalablesyslog.scheduler.drains`- total number of syslog drain bindings 


### Other Configurations

**Note: The default behavior for syslog-drain cert verification has changed
with this release. It now will validate certificates by default, to override
this setting you can set the property `scalablesyslog.adapter.syslog_skip_cert_verify`**

By default, scalable syslog services all syslog drain bindings. It is possible
to configure scalable syslog as opt-in only. To do so, first deploy the system
with the `scalablesyslog.scheduler.require_opt_in` property to `true` within
the `scheduler` job.

Users can then opt to use scalable syslog by appending a `drain-version=2.0`
query parameter to their syslog drain URL when creating a user provided
service. Scalable syslog will ignore bindings without the query parameter.

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
[scalable-syslog]:     https://code.cloudfoundry.org/scalable-syslog
[cf-deployment]:       https://github.com/cloudfoundry/cf-deployment
[sample-manifest]:     https://code.cloudfoundry.org/scalable-syslog-release/blob/master/manifests/scalable-syslog.yml
[common-cloud-config]: https://github.com/cloudfoundry/bosh-deployment/blob/master/warden/cloud-config.yml
