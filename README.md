# CF Syslog Drain Release [![slack.cloudfoundry.org][slack-badge]][loggregator-slack] [![CI Badge][ci-badge]][ci-pipeline]

CF syslog drain release is a [Bosh][bosh] release that works in conjunction with
[Loggregator][loggregator] to bind applications to syslog readers. It can be
independently scaled to support large numbers of [User Provided syslog
drains][syslog-drain-docs].

The [Loggregator Design Notes][loggregator-design-notes] present an overview
of Loggregator components and architecture.

## Supported Features and Release
This release is tested to work with cf-deployment only and is currently included
in cf-deployment by default. Syslog drains in cf-release are still handled by
Dopplers.

### Drain Types (Experimental)
Syslog drains now support an experimental feature that you can opt into by dowloading
the [cf-drain-cli plugin](https://github.com/cloudfoundry-incubator/cf-drain-cli). This
plugin allows you to specify the following "drain types".

 * `logs` - this is the default behavior and will deliver all application logs
 * `metrics` - this will deliver any metric for an application every 15 seconds
 * `all` - this will deliver both metrics and logs for an application

This sample [drain application](https://github.com/cloudfoundry-incubator/loggregator-tools#syslog-to-datadog) can be used to demo this functionality with datadog. **Note** This requires setting the property
(`scalablesyslog.adapter.metrics_to_syslog_enabled`)[https://github.com/cloudfoundry/cf-syslog-drain-release/blob/develop/jobs/adapter/spec#L61] to true. 



### Log Ordering
Ensuring log ordering in drains can be an important consideration for both operators 
and developers. Diego uses a nanosecond based timestamp that can be ingested properly 
by both [ELK](https://www.elastic.co/guide/en/elasticsearch/reference/5.0/date.html) and [Splunk](https://answers.splunk.com/answers/1946/time-format-and-subseconds.html) with the instructions linked. 

Additionally a workaround exists specifically for [Java stack traces](https://github.com/cloudfoundry/loggregator-release/blob/develop/docs/java-multi-line-work-around.md) and ElK. 

### Configuring CF Syslog Drain Components

The cf syslog drain release contains three components.

#### Scheduler

This component handles communication with the Cloud Controller to receive new
bindings. It should not be scaled beyond a single instance.

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
- `loggregator.rlp.egress` - egress out of reverse log proxy
- `cf-syslog-drain.adapter.ingress` - ingress into adapters (these are tagged by index and drain protocol)
- `cf-syslog-drain.adapter.engress` - engress out of adapters (these are tagged by index and drain protocol)
- `cf-syslog-drain.adapter.dropped` - dropped messages on adapters (these are tagged by index and drain protocol)
- `cf-syslog-drain.scheduler.drains`- total number of syslog drain bindings

### Other Configurations

**Note: The default behavior for syslog-drain cert verification has changed
with this release. It now will validate certificates by default. To override
this setting you can set the property:
`scalablesyslog.adapter.syslog_skip_cert_verify`.**

### Deploying CF Syslog Drain Release (standalone)

The release is built to be deployed independently. It can also be used as a
composite release within [cf-deployment][cf-deployment]. The following steps
are for deploying it independently.

The provided [manifest][sample-manifest] is setup to use the [common cloud
config][common-cloud-config].

To deploy to bosh-lite run the following commands:

```bash
bosh -e lite upload-release https://bosh.io/d/github.com/cloudfoundry-incubator/consul-release
bosh -e lite update-cloud-config $HOME/workspace/bosh-deployment/warden/cloud-config.yml
cd $HOME/workspace/cf-syslog-drain-release
bosh create-release --force
bosh -e lite upload-release --rebase
bosh -e lite -d cf-syslog-drain deploy manifests/cf-syslog-drain.yml -o manifests/fake-ops.yml --vars-store=/tmp/bosh-lite-ss.yml
```

### Generating Certificates

To deploy the cf syslog drain release, you will need three sets of certificates for
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

[slack-badge]:              https://slack.cloudfoundry.org/badge.svg
[loggregator-slack]:        https://cloudfoundry.slack.com/archives/loggregator
[bosh]:                     https://bosh.io
[loggregator]:              https://code.cloudfoundry.org/loggregator
[loggregator-design-notes]: https://code.cloudfoundry.org/loggregator/tree/develop/docs/loggregator-design.md
[syslog-drain-docs]:        https://docs.cloudfoundry.org/devguide/services/log-management.html
[cf-deployment]:            https://code.cloudfoundry.org/cf-deployment
[sample-manifest]:          https://code.cloudfoundry.org/cf-syslog-drain-release/blob/master/manifests/cf-syslog-drain.yml
[common-cloud-config]:      https://code.cloudfoundry.org/bosh-deployment/blob/master/warden/cloud-config.yml
[ci-badge]:                 https://loggregator.ci.cf-app.com/api/v1/teams/main/pipelines/loggregator/jobs/cf-syslog-drain-tests/badge
[ci-pipeline]:              https://loggregator.ci.cf-app.com/teams/main/pipelines/loggregator?groups=cf-syslog-drain
