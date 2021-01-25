# TP-Link Archer A6/C6 Container

File system to fiddle with the router's configuration files.

### Bin Structure

```
config.bin/
├─ ori-backup-certificate.bin/
└─ ori-backup-user-config.bin/
    └─ tmp/
        └─ user-config.xml
```

### Dependencies

```
qemu-user-static
```

### Getting Started

- Container
```
$ scripts/run.sh -h
```

- Configuration
```
# config -h
```
