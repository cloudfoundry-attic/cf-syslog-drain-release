
## Isolated Adapter Test

First generate certs under:

`~/workspace/cf-syslog-drain-release/scalable-syslog-certs`

Run dummy metron:

```bash
cd ~/workspace/loggregator
go install tools/dummymetron
bin/dummymetron \
    -grpc-port 12348 \
    -ca ~/workspace/cf-syslog-drain-release/scalable-syslog-certs/scalable-syslog-ca.crt \
    -cert ~/workspace/cf-syslog-drain-release/scalable-syslog-certs/ss-adapter.crt \
    -key ~/workspace/cf-syslog-drain-release/scalable-syslog-certs/ss-adapter.key
```

Run fake syslog consumer:

```bash
bin/fake_consumer -addr :12346 -delay 0s 2> /dev/null
```

Run fake logs provider:

```bash
bin/fake_logs_provider \
    -addr :12345 \
    -ca ./scalable-syslog-certs/scalable-syslog-ca.crt \
    -cert ./scalable-syslog-certs/ss-adapter.crt \
    -key ./scalable-syslog-certs/ss-adapter.key \
    -cn reverselogproxy \
    -delay 0ms
```

Run adapter:

```bash
bin/adapter \
    -addr :12347 \
    -ca ./scalable-syslog-certs/scalable-syslog-ca.crt \
    -cert ./scalable-syslog-certs/ss-adapter.crt \
    -key ./scalable-syslog-certs/ss-adapter.key \
    -cn ss-adapter \
    -logs-api-addr localhost:12345 \
    -metric-ingress-addr :12348 \
    -metric-ingress-cn ss-adapter \
    -rlp-ca ./scalable-syslog-certs/scalable-syslog-ca.crt \
    -rlp-cert ./scalable-syslog-certs/ss-adapter.crt \
    -rlp-key ./scalable-syslog-certs/ss-adapter.key \
    -rlp-cn ss-adapter \
    -syslog-skip-cert-verify true
```

Run fake scheduler:

```bash
go install code.cloudfoundry.org/scalable-syslog/tools/fake_scheduler
bin/fake_scheduler \
    -addr :12347 \
    -ca ~/workspace/cf-syslog-drain-release/scalable-syslog-certs/scalable-syslog-ca.crt \
    -cert ~/workspace/cf-syslog-drain-release/scalable-syslog-certs/ss-scheduler.crt \
    -key ~/workspace/cf-syslog-drain-release/scalable-syslog-certs/ss-scheduler.key \
    -cn ss-adapter \
    -lifetime 15s \
    -delay 10ms
```


