# Scalable Syslog Release

Scalable syslog is a [Bosh][bosh] release that works in conjunction with
[Loggregator][loggregator] to bind applications to syslog readers. It can be
independently scaled to support large numbers of [User Provided syslog
drains][syslog-drain-docs].

The [Loggregator Design Notes][loggregator-design-notes] present an overview
of Loggregator components and architecture.

### Configuring Scalable Syslog Components

The scalable syslog release contains three components.

#### Scheduler

This component handles communication with the Cloud Controller to receive new
bindings. It does not need to be scaled beyond a single instance.

#### Reverse Log Proxy (RLP)

This component scales in conjunction with your overall log volume. We
recommend no less than 2 instances for High Availability and 1/2 your number
of Traffic Controllers. Note that RLP is a component of the [Loggregator
release][loggregator].

#### Syslog Adapter

This component manages the connections to drains. It should be scaled with the
number of drains. A general rule of thumb is to plan for no less than 2
instances and 1 additional instance for every 500 drain bindings. Otherwise,
adapters are reporting dropped.

### Operator Metrics

The following new metrics are emitted:

- `loggregator.rlp.ingress` - ingress into reverse log proxy
- `loggregatopr.rlp.egress` - egress out of reverse log proxy
- `scalablesyslog.adapter.ingress` - ingress into adapters (these are tagged by index and drain protocol)
- `scalablesyslog.adapter.engress` - engress out of adapters (these are tagged by index and drain protocol)
- `scalablesyslog.adapter.dropped` - dropped messages on adapters (these are tagged by index and drain protocol)
- `scalablesyslog.scheduler.drains`- total number of syslog drain bindings

### Other Configurations

**Note: The default behavior for syslog-drain cert verification has changed
with this release. It now will validate certificates by default. To override
this setting you can set the property:
`scalablesyslog.adapter.syslog_skip_cert_verify`.**

By default, scalable syslog services all syslog drain bindings. It is possible
to configure scalable syslog as opt-in only.

To deploy scalable syslog with opt-in enabled:

1. Deploy the system with the `scalablesyslog.scheduler.require_opt_in`
   property set to `true` within the `scheduler` job.
1. When creating a user provided service, users can opt to use scalable syslog
   by appending a `drain-version=2.0` query parameter to their syslog drain
   URL. Scalable syslog will ignore bindings without the query parameter.

### Deploying Scalable Syslog (standalone)

The release is built to be deployed independently. It can also be used as a
composite release within [cf-deployment][cf-deployment]. The following steps
are for deploying it independently.

The provided [manifest][sample-manifest] is setup to use the [common cloud
config][common-cloud-config].

To deploy to bosh-lite run the following commands:

```bash
bosh -e lite upload-release https://bosh.io/d/github.com/cloudfoundry-incubator/consul-release
bosh -e lite update-cloud-config $HOME/workspace/bosh-deployment/warden/cloud-config.yml
cd $HOME/workspace/scalable-syslog-release
bosh create-release --force
bosh -e lite upload-release --rebase
bosh -e lite -d scalablesyslog deploy manifests/scalable-syslog.yml -o manifests/fake-ops.yml --vars-store=/tmp/bosh-lite-ss.yml
```

### Generating Certificates

To deploy the scalable syslog, you will need three sets of certificates for
the following connections:

- The scheduler to Cloud Controller
- The scheduler to the adapters
- The adapters to the reverse log proxies

To generate these certs, you will need the CA used within Loggregator, as well
as the CA used to sign the Cloud Controller certificate. This is typically
the diego BBS CA.

Assuming you have these two CAs, run the following commands:

```bash
./scripts/generate-certs bbs-ca.crt bbs-ca.key loggregator-ca.crt loggregator-ca.key
```

[bosh]:                     https://bosh.io
[loggregator]:              https://code.cloudfoundry.org/loggregator
[loggregator-design-notes]: https://code.cloudfoundry.org/loggregator/tree/develop/docs/loggregator-design.md
[syslog-drain-docs]:        https://docs.cloudfoundry.org/devguide/services/log-management.html
[cf-deployment]:            https://code.cloudfoundry.org/cf-deployment
[sample-manifest]:          https://code.cloudfoundry.org/scalable-syslog-release/blob/master/manifests/scalable-syslog.yml
[common-cloud-config]:      https://code.cloudfoundry.org/bosh-deployment/blob/master/warden/cloud-config.yml
