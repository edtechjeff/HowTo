# Windows Server 2022 Container Demo with IIS

This guide demonstrates how to install Windows Container support on Windows Server 2022 and deploy a simple IIS website inside a Windows container.

The demonstration is designed to show the difference between a traditional virtual machine and a container, as well as introduce the concepts of **containers, images, Dockerfiles, and reproducible deployments**.

> **Note:** A container is not simply a small virtual machine. Containers package applications and their dependencies into isolated environments. Windows containers can use process isolation or Hyper-V isolation.

---

## 1. Install the Containers Feature

Open **PowerShell as Administrator**.

Install the Windows Containers feature:

```powershell
Install-WindowsFeature Containers -Restart
```

The server will restart.

After logging back in, verify the feature:

```powershell
Get-WindowsFeature Containers
```

You should see:

```text
Display Name        Name          Install State
------------        ----          -------------
[X] Containers      Containers    Installed
```

---

## 2. Verify the Container Runtime

The Windows Containers feature provides Windows container support, but a **container runtime** is also required.

If Docker or another compatible runtime has already been installed, verify it:

```powershell
docker version
```

Also check:

```powershell
docker info
```

If the `docker` command is not recognized, the container runtime still needs to be installed and configured.

> **Important:** Installing the Windows `Containers` feature by itself does not install Docker.

---

## 3. Download the IIS Container Image

Microsoft provides Windows container images through the Microsoft Container Registry.

Download the Windows Server 2022 IIS image:

```powershell
docker pull mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2022
```

This can take some time during the first download.

Verify the image:

```powershell
docker images
```

You should see an image similar to:

```text
REPOSITORY                                  TAG
mcr.microsoft.com/windows/servercore/iis    windowsservercore-ltsc2022
```

---

# Part 1 - Run Your First IIS Container

## 4. Create the IIS Container

Run:

```powershell
docker run -d `
    -p 8080:80 `
    --name WebDemo `
    mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2022
```

The options mean:

| Option | Purpose |
|---|---|
| `docker run` | Creates and starts a container |
| `-d` | Runs the container in the background |
| `-p 8080:80` | Maps host TCP port 8080 to container TCP port 80 |
| `--name WebDemo` | Names the container `WebDemo` |

---

## 5. Verify the Container

Run:

```powershell
docker ps
```

You should see `WebDemo` running.

To see all containers, including stopped containers:

```powershell
docker ps -a
```

---

## 6. Open the Website

Determine the IP address of the Windows Server:

```powershell
Get-NetIPAddress -AddressFamily IPv4
```

From another computer, browse to:

```text
http://SERVER-IP:8080
```

For example:

```text
http://192.168.0.50:8080
```

You should see the default IIS website.

---

# Part 2 - Modify the Running Container

One way to demonstrate how containers work is to modify the website directly inside the running container.

## 7. Open PowerShell Inside the Container

Run:

```powershell
docker exec -it WebDemo powershell
```

Your PowerShell session is now running **inside the container**.

Change to the IIS web root:

```powershell
cd C:\inetpub\wwwroot
```

List the files:

```powershell
dir
```

The standard IIS web root is:

```text
C:\inetpub\wwwroot
```

---

## 8. Remove the Default IIS Page

Run:

```powershell
Remove-Item C:\inetpub\wwwroot\iisstart.htm -ErrorAction SilentlyContinue
```

---

## 9. Create a Custom Website

While still inside the container, run:

```powershell
@"
<html>
<head>
    <title>Hyper-V Container Demo</title>
</head>

<body>

    <h1>Hello from my Windows Container!</h1>

    <h2>Windows Server 2022 + IIS</h2>

    <p>This website is running inside a Windows container.</p>

</body>
</html>
"@ | Set-Content C:\inetpub\wwwroot\index.html
```

Verify the file:

```powershell
Get-Content C:\inetpub\wwwroot\index.html
```

Exit the container:

```powershell
exit
```

Refresh:

```text
http://SERVER-IP:8080
```

The custom website should now appear.

---

# Part 3 - Demonstrate Container Lifecycle

This is an excellent point to demonstrate how quickly containers can be stopped and started.

## Stop the Container

```powershell
docker stop WebDemo
```

Check:

```powershell
docker ps
```

Refresh the website.

It should no longer respond.

---

## Start the Container

```powershell
docker start WebDemo
```

Refresh the website.

The website should return almost immediately.

---

## View Container Status

```powershell
docker ps -a
```

---

# Part 4 - Delete the Container

Now demonstrate an important container concept.

Delete the container:

```powershell
docker rm -f WebDemo
```

Verify:

```powershell
docker ps -a
```

The `WebDemo` container should be gone.

Refresh the website.

The website is gone as well.

---

# Part 5 - Recreate the Original Container

Run the original Microsoft IIS image again:

```powershell
docker run -d `
    -p 8080:80 `
    --name WebDemo `
    mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2022
```

Open:

```text
http://SERVER-IP:8080
```

Notice that your custom website is **gone**.

The container was recreated from the original Microsoft image.

This demonstrates an important container concept:

> **Changes made manually inside a container are not how applications should normally be deployed. Containers should be reproducible from an image.**

Remove the demonstration container again:

```powershell
docker rm -f WebDemo
```

---

# Part 6 - Build Our Own Container Image

Now we will create our own image containing the custom website.

Create a working directory:

```powershell
New-Item -ItemType Directory -Path C:\ContainerDemo -Force
```

Change into it:

```powershell
cd C:\ContainerDemo
```

Our directory will eventually contain:

```text
C:\ContainerDemo
│
├── Dockerfile
└── index.html
```

---

## 10. Create index.html

Create the website:

```powershell
@"
<html>

<head>
    <title>Container Demo</title>
</head>

<body>

    <h1>My IIS Container</h1>

    <h2>Windows Server 2022</h2>

    <p>Hello from my Windows container!</p>

    <p>This website was built directly into a container image.</p>

</body>

</html>
"@ | Set-Content C:\ContainerDemo\index.html
```

Verify:

```powershell
Get-Content C:\ContainerDemo\index.html
```

---

# Part 7 - Create the Dockerfile

A **Dockerfile** contains the instructions used to build a container image.

Create the file:

```powershell
New-Item -Path C:\ContainerDemo\Dockerfile -ItemType File
```

> **Important:** The file must be named exactly `Dockerfile`.
>
> It should NOT be:
>
> ```text
> Dockerfile.txt
> ```

Open it with Notepad:

```powershell
notepad C:\ContainerDemo\Dockerfile
```

Add:

```dockerfile
FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2022

RUN powershell -Command Remove-Item C:\inetpub\wwwroot\iisstart.htm -Force

COPY index.html C:/inetpub/wwwroot/index.html
```

Save the file.

---

# Part 8 - Understand the Dockerfile

### FROM

```dockerfile
FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2022
```

This specifies the image we are starting with.

In this example, Microsoft provides:

- Windows Server Core
- IIS
- Container image

---

### RUN

```dockerfile
RUN powershell -Command Remove-Item C:\inetpub\wwwroot\iisstart.htm -Force
```

This removes the default IIS start page while the image is being built.

---

### COPY

```dockerfile
COPY index.html C:/inetpub/wwwroot/index.html
```

This copies our custom website into the container image.

---

# Part 9 - Build the Image

Make sure you are in:

```powershell
cd C:\ContainerDemo
```

Verify:

```powershell
dir
```

You should have:

```text
Dockerfile
index.html
```

Build the image:

```powershell
docker build -t my-iis-site .
```

The period at the end is important:

```text
.
```

It tells Docker to use the current directory as the build context.

---

## 11. Verify the Image

Run:

```powershell
docker images
```

You should now see:

```text
my-iis-site
```

This is **our image**, rather than Microsoft's original IIS image.

---

# Part 10 - Run Our Custom Image

Create a container from our image:

```powershell
docker run -d `
    -p 8080:80 `
    --name WebDemo `
    my-iis-site
```

Check it:

```powershell
docker ps
```

Browse to:

```text
http://SERVER-IP:8080
```

Our custom website should appear.

---

# Part 11 - Destroy and Recreate It

Here's the important demonstration.

Delete the container:

```powershell
docker rm -f WebDemo
```

The container is completely gone.

Verify:

```powershell
docker ps -a
```

Now recreate it:

```powershell
docker run -d `
    -p 8080:80 `
    --name WebDemo `
    my-iis-site
```

Refresh the website.

The customized website returns immediately.

Why?

Because the website is now part of the **image**.

---

# Container vs Image

It is important to understand the difference.

```text
Dockerfile
    │
    │ docker build
    ▼
Container Image
    │
    │ docker run
    ▼
Running Container
```

The **Dockerfile** contains the build instructions.

The **image** is the reusable application package created from those instructions.

The **container** is a running instance of that image.

You can create many containers from the same image.

---

# Container vs Virtual Machine

A traditional Hyper-V environment might look like:

```text
Physical Server
│
└── Hyper-V
    │
    ├── VM01
    │   ├── Virtual Hardware
    │   ├── Windows Server
    │   └── IIS
    │
    └── VM02
        ├── Virtual Hardware
        ├── Windows Server
        └── Application
```

With containers:

```text
Windows Server
│
├── Container Runtime
│
├── Container: Website
│   └── IIS Application
│
├── Container: Application
│   └── Application
│
└── Container: Service
    └── Service
```

Rather than deploying an entire server for every application, containers allow applications to be packaged into isolated and reproducible environments.

---

# Useful Docker Commands

List running containers:

```powershell
docker ps
```

List all containers:

```powershell
docker ps -a
```

List images:

```powershell
docker images
```

Stop a container:

```powershell
docker stop WebDemo
```

Start a container:

```powershell
docker start WebDemo
```

Restart a container:

```powershell
docker restart WebDemo
```

Open PowerShell inside a container:

```powershell
docker exec -it WebDemo powershell
```

View container logs:

```powershell
docker logs WebDemo
```

Delete a container:

```powershell
docker rm -f WebDemo
```

Delete an image:

```powershell
docker image rm my-iis-site
```

---

# Key Takeaways

A **virtual machine** virtualizes a complete computer and normally runs a complete guest operating system.

A **container** provides an isolated environment for an application without requiring a traditional full VM for every application instance.

A **container image** is the reusable package used to create containers.

A **Dockerfile** documents how an image should be built.

Instead of manually configuring containers after they are created, applications and configuration should normally be incorporated into the image.

This makes container deployments:

- Repeatable
- Portable
- Consistent
- Easy to destroy and recreate

The most important concept demonstrated in this lab is:

> **Don't build the server and then install the application. Define the application environment and reproduce it from the image.**