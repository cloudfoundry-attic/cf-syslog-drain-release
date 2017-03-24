
## How to deploy to bosh-lite

This manifest requires the use of the [warden bosh-deployment cloud-config][cloud-config].

To deploy this release using fake bindings provider and fake logs provider run
the following commands:

```bash
bosh -e lite update-cloud-config ~/workspace/bosh-deployment/cloud-config.yml
bosh -e lite -d scalablesyslog manifests/scalable-syslog.yml -o manifests/fake-ops.yml
```

[cloud-config]: https://github.com/cloudfoundry/bosh-deployment/blob/master/warden/cloud-config.yml
