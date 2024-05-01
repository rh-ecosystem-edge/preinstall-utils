# preinstall-utils

A common Go library with some helper functions used before installing OCP operating systems to disk. At the moment it's used to share similar disk cleanup code between the [Assisted Installer](https://github.com/openshift/assisted-installer/) and the [Lifecycle Agent](https://github.com/openshift-kni/lifecycle-agent/) projects.

## Disk Cleanup

The `preinstall-utils` library provides a function to clean up the disk before installing an operating system. This function is used to remove any existing partitions and file systems from the disk, ensuring that the disk is in a clean state before installing the operating system.

### Disk Cleanup Usage

```go 
    
    import preinstallUtils "github.com/rh-ecosystem-edge/preinstall-utils/pkg"
    ...

    device := "/dev/sda"
    logger := logrus.New()
    cleanupDevice := preinstallUtils.NewCleanupDevice(logger, preinstallUtils.NewDiskOps(logger, executor))
    err := cleanupDevice.CleanupDevice(device)
    if err != nil {
        return err
    }
```