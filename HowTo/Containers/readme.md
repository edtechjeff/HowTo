# Windows Server 2022 Containers with Docker and IIS

This guide walks through installing Windows container support on **Windows Server 2022**, installing Docker Engine, deploying an IIS container, modifying a running container, and finally building a custom reusable container image.

The goal of this lab is to demonstrate the difference between:

- Virtual machines
- Containers
- Container images
- Running containers
- Dockerfiles
- Reproducible application deployments

---

# Lab Overview

By the end of this lab, we will have:

```text
Windows Server 2022
│
├── Containers Windows Feature
│
├── Docker Engine
│
├── Microsoft IIS Container Image
│
└── WebDemo Container
    │
    └── IIS
        │
        └── Custom Website
```

The website will be accessible using:

```text
http://SERVER-IP:8080
```

---

# 1. Install the Windows Containers Feature

Open **PowerShell as Administrator**.

Install the Windows Containers feature:

```powershell
Install-WindowsFeature -Name Containers
```

Verify the installation:

```powershell
Get-WindowsFeature Containers
```

You should see:

```text
Display Name        Name          Install State
------------        ----          -------------
[X] Containers      Containers    Installed
```

> **Important**
>
> Installing the Windows `Containers` feature does **not** install Docker.
>
> The Windows feature provides the operating-system components required to support Windows containers. A container runtime is still required to create and manage containers.

---

# 2. Install Docker Engine

Download the Docker installation helper script:

```powershell
Invoke-WebRequest -UseBasicParsing `
"https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-DockerCE/install-docker-ce.ps1" `
-OutFile install-docker-ce.ps1
```

Run the installation script:

```powershell
.\install-docker-ce.ps1
```

The installation may require the server to restart.

Allow the server to reboot if necessary.

---

# 3. Verify Docker Installation

After the server restarts, open **PowerShell as Administrator**.

Check Docker:

```powershell
docker version
```

Check the Docker service:

```powershell
Get-Service docker
```

The service should show:

```text
Status   Name
------   ----
Running  docker
```

Additional Docker information can be displayed with:

```powershell
docker info
```

At this point we have two separate components:

```text
Windows Server 2022
│
├── Containers Feature
│   │
│   └── Provides Windows container support
│
└── Docker Engine
    │
    └── Creates and manages containers
```

Docker Engine provides commands for:

- Pulling images
- Building images
- Creating containers
- Starting containers
- Stopping containers
- Removing containers
- Viewing container status

---

# 4. Pull the Windows Server 2022 IIS Image

Microsoft provides Windows container images through the Microsoft Container Registry.

Download the Windows Server 2022 IIS image:

```powershell
docker pull mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2022
```

The initial download may take some time because the Windows Server Core container image is relatively large.

Verify the image:

```powershell
docker images
```

You should see something similar to:

```text
REPOSITORY                                  TAG
mcr.microsoft.com/windows/servercore/iis    windowsservercore-ltsc2022
```

---

# 5. Create the IIS Container

Create a container named `WebDemo`:

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
| `-p 8080:80` | Maps host port 8080 to container port 80 |
| `--name WebDemo` | Names the container `WebDemo` |

The port mapping can be visualized as:

```text
Client Computer
      │
      │ HTTP
      ▼
Windows Server
Port 8080
      │
      │ Docker Port Mapping
      ▼
WebDemo Container
Port 80
      │
      ▼
     IIS
```

---

# 6. Verify the Container

Display running containers:

```powershell
docker ps
```

You should see the `WebDemo` container.

To display both running and stopped containers:

```powershell
docker ps -a
```

---

# 7. Open the IIS Website

Determine the IP address of the Windows Server:

```powershell
Get-NetIPAddress -AddressFamily IPv4
```

From another computer, open a browser and navigate to:

```text
http://SERVER-IP:8080
```

For example:

```text
http://192.168.0.50:8080
```

You should see the default IIS website.

---

# 8. Open PowerShell Inside the Container

One of the easiest ways to demonstrate container isolation is to open a PowerShell session inside the running container.

Run:

```powershell
docker exec -it WebDemo powershell
```

You are now executing PowerShell **inside the container**.

Change to the IIS web directory:

```powershell
cd C:\inetpub\wwwroot
```

Display the files:

```powershell
dir
```

The standard IIS web root is:

```text
C:\inetpub\wwwroot
```

---

# 9. Remove the Default IIS Page

While still inside the container, remove the default IIS page:

```powershell
Remove-Item C:\inetpub\wwwroot\iisstart.htm -ErrorAction SilentlyContinue
```

---

# 10. Create a Custom Website

While still inside the container, create a new `index.html`:

```powershell
@"
<html>

<head>
    <title>Windows Container Demo</title>
</head>

<body>

    <h1>Hello from my Windows Container!</h1>

    <h2>Windows Server 2022 + Docker + IIS</h2>

    <p>This website is being served from inside a Windows container.</p>

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

# 11. Stop the Container

Stop the container:

```powershell
docker stop WebDemo
```

Check its status:

```powershell
docker ps
```

Because `docker ps` only displays running containers, `WebDemo` should no longer appear.

Display all containers:

```powershell
docker ps -a
```

`WebDemo` should now show as stopped.

Refresh the website.

The website should no longer respond.

---

# 12. Start the Container

Start it again:

```powershell
docker start WebDemo
```

Verify:

```powershell
docker ps
```

Refresh:

```text
http://SERVER-IP:8080
```

The website should return very quickly.

This demonstrates one of the major differences between starting a traditional virtual machine and starting an existing container.

---

# 13. Delete the Container

Now we can demonstrate an important container concept.

Delete the container:

```powershell
docker rm -f WebDemo
```

Verify:

```powershell
docker ps -a
```

`WebDemo` should be gone.

Refresh the website.

The website is also gone.

---

# 14. Recreate the Container from the Microsoft Image

Create another container using the original Microsoft IIS image:

```powershell
docker run -d `
    -p 8080:80 `
    --name WebDemo `
    mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2022
```

Browse to:

```text
http://SERVER-IP:8080
```

Notice something important:

**Our customized website is gone.**

The container was created from Microsoft's original IIS image, so it returned to its original state.

This demonstrates an important container principle:

> **Containers should generally be treated as disposable. Important application configuration should be built into an image or stored outside the container rather than manually configured inside a running container.**

Remove this container before continuing:

```powershell
docker rm -f WebDemo
```

---

# 15. Build Our Own Container Image

Instead of manually changing the container every time it is created, we can build our website into our own image.

Create a working directory:

```powershell
New-Item -ItemType Directory -Path C:\ContainerDemo -Force
```

Change into it:

```powershell
cd C:\ContainerDemo
```

Eventually the directory will contain:

```text
C:\ContainerDemo
│
├── Dockerfile
│
└── index.html
```

---

# 16. Create index.html

Create the website:

```powershell
@"
<html>

<head>
    <title>My Container Website</title>
</head>

<body>

    <h1>My IIS Container</h1>

    <h2>Windows Server 2022</h2>

    <p>Hello from my custom Windows container!</p>

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

# 17. Create the Dockerfile

A **Dockerfile** contains the instructions Docker uses to build an image.

Create the Dockerfile:

```powershell
@"
FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2022

RUN powershell -Command Remove-Item C:\inetpub\wwwroot\iisstart.htm -Force

COPY index.html C:/inetpub/wwwroot/index.html
"@ | Set-Content -Path .\Dockerfile
```

> **Important**
>
> The file must be named:
>
> ```text
> Dockerfile
> ```
>
> Not:
>
> ```text
> Dockerfile.txt
> ```

Verify:

```powershell
Get-ChildItem C:\ContainerDemo
```

You should see:

```text
Dockerfile
index.html
```

---

# 18. Understanding the Dockerfile

The Dockerfile contains three primary instructions.

## FROM

```dockerfile
FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2022
```

`FROM` specifies the base image.

We are starting with Microsoft's Windows Server Core IIS image.

Conceptually:

```text
Microsoft Windows Server Core + IIS
                │
                ▼
          Our Dockerfile
                │
                ▼
        Our Custom Image
```

---

## RUN

```dockerfile
RUN powershell -Command Remove-Item C:\inetpub\wwwroot\iisstart.htm -Force
```

This executes a command while the image is being built.

In this case, it removes the default IIS start page.

---

## COPY

```dockerfile
COPY index.html C:/inetpub/wwwroot/index.html
```

This copies our custom `index.html` from the build directory into the image.

---

# 19. Build the Custom Image

Make sure you are in the correct directory:

```powershell
cd C:\ContainerDemo
```

Check:

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

It means:

> Use the current directory as the Docker build context.

---

# 20. Verify the Custom Image

Display the available images:

```powershell
docker images
```

You should now see:

```text
my-iis-site
```

You now have two important images:

```text
Microsoft IIS Image
        │
        │ Dockerfile
        ▼
  my-iis-site
```

---

# 21. Create a Container from Our Image

Create a new container:

```powershell
docker run -d `
    -p 8080:80 `
    --name WebDemo `
    my-iis-site
```

Verify:

```powershell
docker ps
```

Browse to:

```text
http://SERVER-IP:8080
```

The custom website should appear.

---

# 22. Destroy and Recreate the Container

Now comes the most useful part of the demonstration.

Delete the container:

```powershell
docker rm -f WebDemo
```

Verify that it is gone:

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

Refresh:

```text
http://SERVER-IP:8080
```

The customized website immediately returns.

Why?

Because the website is now part of the **image**.

---

# Dockerfile vs Image vs Container

These three concepts are important to understand:

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

## Dockerfile

The Dockerfile contains the **instructions** for creating an image.

Think of it as the recipe.

## Image

The image is the **reusable application package** created from the Dockerfile.

It can be used repeatedly to create containers.

## Container

A container is a **running instance of an image**.

Multiple containers can be created from the same image.

For example:

```text
             my-iis-site
                  │
        ┌─────────┼─────────┐
        │         │         │
        ▼         ▼         ▼
     Web01      Web02      Web03
```

All three containers could be created from exactly the same image.

---

# Containers vs Virtual Machines

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

Each virtual machine contains its own operating-system environment.

Containers approach application deployment differently:

```text
Windows Server
│
├── Container Runtime
│
├── Web Container
│   └── IIS Website
│
├── Application Container
│   └── Application
│
└── Service Container
    └── Service
```

Containers are designed around packaging and running applications rather than creating another traditional server for every application.

---

# Windows Container Isolation

Windows containers can use different isolation models.

## Process Isolation

With process isolation, containers share the host Windows kernel while maintaining isolated application environments.

Conceptually:

```text
Windows Server Host
│
├── Windows Kernel
│
├── Container A
├── Container B
└── Container C
```

## Hyper-V Isolation

Windows containers can also use **Hyper-V isolation**.

In this mode, Hyper-V provides an additional isolation boundary using a lightweight utility virtual machine.

Conceptually:

```text
Windows Server
│
└── Hyper-V
    │
    └── Lightweight Utility VM
        │
        └── Container
```

This is a useful demonstration of how **Hyper-V and containers can work together rather than being competing technologies**.

---

# Useful Docker Commands

## Show Running Containers

```powershell
docker ps
```

## Show All Containers

```powershell
docker ps -a
```

## Show Images

```powershell
docker images
```

## Stop a Container

```powershell
docker stop WebDemo
```

## Start a Container

```powershell
docker start WebDemo
```

## Restart a Container

```powershell
docker restart WebDemo
```

## Open PowerShell Inside a Container

```powershell
docker exec -it WebDemo powershell
```

## View Container Logs

```powershell
docker logs WebDemo
```

## Inspect a Container

```powershell
docker inspect WebDemo
```

## Delete a Container

```powershell
docker rm -f WebDemo
```

## Delete an Image

```powershell
docker image rm my-iis-site
```

---

# Complete Lab Workflow

The complete workflow used in this demonstration is:

```text
1. Install Windows Containers feature
              │
              ▼
2. Install Docker Engine
              │
              ▼
3. Pull Microsoft IIS image
              │
              ▼
4. Create WebDemo container
              │
              ▼
5. View default IIS website
              │
              ▼
6. Modify website inside container
              │
              ▼
7. Delete container
              │
              ▼
8. Discover manual changes are gone
              │
              ▼
9. Create index.html
              │
              ▼
10. Create Dockerfile
              │
              ▼
11. Build my-iis-site image
              │
              ▼
12. Create WebDemo from our image
              │
              ▼
13. Delete WebDemo
              │
              ▼
14. Recreate WebDemo
              │
              ▼
15. Website immediately returns
```

---

# Key Takeaways

A **virtual machine** virtualizes a complete computer and normally contains a complete guest operating-system environment.

A **container** packages an application into an isolated and reproducible environment.

A **container image** is the reusable package used to create containers.

A **Dockerfile** contains the instructions for building an image.

A **running container** is an instance of an image.

The Windows **Containers feature** provides Windows container support but does not by itself install Docker Engine.

Docker Engine provides the tools used to build images and create and manage containers.

Containers should generally be considered **disposable**.

Instead of manually configuring every container after it is created, the desired application and configuration should be defined in the image.

This makes container deployments:

- Repeatable
- Portable
- Consistent
- Easier to automate
- Easy to destroy and recreate

The central idea demonstrated by this lab is:

> **Build the application environment into an image, then create disposable containers from that image.**