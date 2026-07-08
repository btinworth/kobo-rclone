# kobo-rclone

Pulls eBooks from the cloud to your Kobo library using [rclone](https://rclone.org).

## Install

1. Download the latest `KoboRoot.tgz` from the latest release:
   <https://github.com/btinworth/kobo-rclone/releases/latest>
2. Copy `KoboRoot.tgz` into your Kobo `.kobo` directory.
3. Reboot the Kobo.
4. Create your rclone config on your computer (`rclone config`) and copy it to:
   `.adds/koborclone/rclone.conf`
5. Edit `.adds/koborclone/koborclone.conf` and add one remote path per line, for example:

   ```conf
   GoogleDrive:Books
   Dropbox:ebooks
   ```

6. Optionally, add a `SYNC` line to `.adds/koborclone/koborclone.conf` to have
   books removed from your Kobo when they're deleted from the sync source
   (uses `rclone sync` instead of `rclone copy`):

   ```conf
   SYNC
   GoogleDrive:Books
   Dropbox:ebooks
   ```

## Acknowledgements

* Based on [KoboClone](https://github.com/fsantini/KoboCloud) by fsantini
* Installs [NickelDBus](https://github.com/shermp/NickelDBus) by shermp if missing
* Depends largely on [rclone](https://github.com/rclone/rclone)
