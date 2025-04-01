# Using RClone to map drive to SharePoint or OneDrive

## In this article we are going to talk about RClone. What is RClone? RClone is a command-line tool for managing and syncing files across various cloud storage providers, including Google Drive, OneDrive, AWS S3, and more. It supports advanced features like encryption, deduplication, and bandwidth throttling, making it a powerful alternative to traditional cloud sync tools. RClone is widely used for backups, migrations, and automation due to its flexibility and scripting capabilities.

In order to get this working you will need the following required software packages

## Required Software

- https://rclone.org/downloads/
- https://winfsp.dev/rel/

1. Once you get that downloaded, extract the RClone to your local device. Rename the folder to just RClone
2. Now that you have RClone downloaded, I would suggest for easier management to add the exe to your systems folder path so its easier to call it out from the command-line.
3. Next install winfsp, just accept the defaults

Now you have the pre-requisites setup

4. bring up a command prompt. In this example we are going to map to a users onedrive folder, but first we must configure it. Run the following command

```
rclone config
```

![alt text](Pictures/1.png)

## Command to Mount SharePoint 

```
rclone --vfs-cache-mode writes mount sharepoint: *
```

## Command (Example of copying file from D drive on local machine to Z drive the mounted SharePoint folder)

```
rclone copy D:\ Z:\ --fast-list --progress --create-empty-src-dirs
```


