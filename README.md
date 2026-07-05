# Kobo Rclone

Syncs your Kobo library from cloud remotes using [rclone](https://rclone.org).

## Install

1. Download the latest `KoboRoot.tgz` from the build workflow artifacts:
   <https://github.com/btinworth/KoboRclone/actions/workflows/build.yml>
2. Copy `KoboRoot.tgz` into your Kobo `.kobo` directory.
3. Reboot the Kobo.
4. Create your rclone config on your computer (`rclone config`) and copy it to:
   `.adds/koborclone/rclone.conf`
5. Edit `.adds/koborclone/koborclone.conf` and add one remote path per line, for example:

```conf
my_drive:Books
my_dropbox:ebooks
```
