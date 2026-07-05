# KoboRclone

A set of scripts to synchronize a kobo reader with popular cloud services, using [rclone](https://rclone.org).

Some example supported cloud services:

- Dropbox
- Google Drive
- NextCloud/OwnCloud
- pCloud
- Box

There are many more - see <https://rclone.org/docs> for the full list.

## Installation

Download the latest `KoboRoot.tgz` from the latest Build action, from [this page](https://github.com/btinworth/KoboRclone/actions/workflows/build.yml).

Copy it into the Kobo device:

- Connect the Kobo device and mount it (you should be able to access to the kobo filesystem)
- Copy the .tgz archive in the .kobo directory(1) of your device
- Unplug and restart your Kobo device

(1) It is a hidden directory, so you have to enable the visualization of hidden files

**Note for Mac/Safari users:** Safari automatically unpacks `KoboRoot.tgz` into `KoboRoot.tar` after downloading. Please make sure that you transfer the `.tgz` file to your Kobo, and **not** the `.tar`. Either use a different browser to download the package, or re-pack it (using `gzip`) before transferring.

## Configuration

After the installation process:

1. [Download](https://rclone.org/downloads/) rclone to your computer
2. Run `rclone config` to create a config file and add your remote Cloud services ([detailed instructions](https://rclone.org/remote_setup/#configuring-by-copying-the-config-file)).
    - You can add as many remote Cloud services as you need, but note the name you give each remote.
3. Plug your Kobo back into the computer
4. Copy the rclone config file to `.add/koborclone/rclone.conf`
    - Run `rclone config file` on your computer to find the file.
5. Edit the configuration file located at `.add/koborclone/koborclonerc`, and add each remote:directory pair (one per line).

## Configuration example

(Note: this is after going through the configuraton steps above)

```ini
# Lines starting with '#' are ignored
# Google drive:
my_google_drive:foldername

# Dropbox:
my_dropbox:other/folder/name
```

rclone supports many, many other remote types. See <https://rclone.org/docs> for the full list.

### Matching remote server

To delete files from library when they are no longer in the remote server:

- Edit the koborclonerc file so it contains the phrase `REMOVE_DELETED` in a single line (all capital, no spaces before or after).
- Restart your Kobo.

The next time the Kobo is connected to the internet, it will delete any files (it will not delete directories) that are not in the remote server.

(This works by running `rclone sync` instead of `rclone copy`),

## Usage

The new files will be downloaded when the kobo connects to the Internet for a sync. Sometimes few minutes is needed after the sync process for the device to recognize and import new downloaded content.

## Uninstallation

To properly uninstall KoboRclone:

- Edit the koborclonerc file so that it contains the word `UNINSTALL` in a single line (all capital, no spaces before or after)
- Restart your Kobo

The next time the Kobo is connected to the Internet, the program will delete itself.

Note: The directory .add/koborclone will not be deleted: after connecting the device to a computer, you should move the files from the Library subfolder in order not to lose your content, and delete the whole koborclone directory manually.

## Installation from source code

To install KoboRclone from source code:

- Download this repository
- Compile the code into an archive format (instructions below)
- Follow installation instructions

### Compiling

- Move to the project directory root
- Open the configuration file located at `src/usr/local/koborclone/koborclonerc.tmpl`
- Add the links to the cloud services (see the configuration example that follow below)
- Run `sh ./makeKoboRoot.sh`

The last command will create a `KoboRoot.tgz` archive.

Now you can follow installation instructions.

## Troubleshooting

KoboRclone keeps a log of each session in the `.add/koborclone/get.log` file. If something goes wrong, useful information can be found there. Please send a copy of this file with every bug report.

## Known issues

Some versions of Kobo make the same book appear twice in the library. This is because it scans the internal directory where the files are saved as well as the "official" folders. To solve this problem find the `Kobo eReader.conf` file inside your `.kobo/Kobo` folder and make sure the following line (which prevents the syncing of dotfiles and dotfolders) is set in the `[FeatureSettings]` section:

```ini
  ExcludeSyncFolders=\\.(?!add|adobe).*?
```

## Acknowledgment

KoboRclone installs [NickelDBus](https://github.com/shermp/NickelDBus) if not present. Thanks to shermp for providing this!
Thanks to the defunct SendToKobo service for the inspiration of the project and for the basis of the scripts.
Thanks to Christoph Burschka for the help in updating this tool to the recent versions of kobo and nextcloud.
Initial rclone changes from <https://github.com/marklar423/KoboCloud-rclone>
