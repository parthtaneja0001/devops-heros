# Docker Networking & Volumes - Homework

Hands-on practice covering Docker container networking, host networks, bind mounts, and overlay networks.

## Task 1: Docker Container Networking

I created 3 containers (`frontend`, `backend`, `database`) distributed across 3 custom networks. The **backend container is connected to multiple networks** so that it acts as a bridge between the frontend and the database.

| Container | Image | Network(s) |
|---|---|---|
| frontend | `nginx:alpine` | `frontend-net` |
| backend | `nginx:alpine` | `backend-net` + `frontend-net` + `db-net` |
| database | `nginx:alpine` | `db-net` |

> Note: The database tier uses `nginx:alpine` as a lightweight stand-in because the VM disk was too small to pull the full `mysql:8.0` image. The networking behavior being tested here—multiple networks, DNS resolution by container name, and isolation between networks—remains exactly the same.

### Create 3 networks
```bash
docker network create frontend-net
docker network create backend-net
docker network create db-net
docker network ls
```

### Create the 3 containers
```bash
docker run -d --name frontend --network frontend-net nginx:alpine
docker run -d --name database --network db-net -e MYSQL_ROOT_PASSWORD=rootpass mysql:8.0
docker run -d --name backend  --network backend-net nginx:alpine
```

### Add the backend to 2 more networks
```bash
docker network connect frontend-net backend
docker network connect db-net backend

# The backend is now on networks: backend-net, db-net, frontend-net
```

### Check connectivity
```bash
# backend -> frontend (shared frontend-net): SUCCESS
docker exec backend wget -qO- http://frontend        # Returns the nginx welcome page

# backend -> database (shared db-net): SUCCESS
docker exec backend nc -z database 3306              # Port 3306 is reachable

# frontend -> database (different networks): FAILS (isolated)
docker exec frontend nc -z database 3306             # nc: bad address 'database'
```

**What I understood:** Containers residing on the **same** Docker network can reach one another by name because Docker provides a built-in DNS service. Containers on **different** networks are strictly isolated. By attaching the backend to multiple networks, it can securely talk to both the frontend and the database, while the frontend cannot reach the database directly. This mirrors how a real 3-tier application keeps its database private.

![Task 1 - networking](screenshots/image1.png)

## Task 2: Host Network

```bash
docker run -d --name web-host --network host nginx:alpine
docker ps                   # Note: The host network mode shows NO port mapping
curl http://localhost:80    # Returns the nginx welcome page
```

**What I understood:** By using `--network host`, the container directly shares the host machine's networking stack. No port mapping (`-p`) is needed, and the service is instantly available on the host's own port 80.

> Note: `nginx:alpine` was used here instead of `httpd:2.4` because the VM disk was full. The host-network behavior is identical—the web server is reachable on the host's port 80 without any `-p` mapping. On a native Linux host, this works directly at `http://localhost:80`. On Docker Desktop (Mac/Windows), host networking binds inside the Docker VM rather than directly to the host's localhost.

![Task 2 - host network](screenshots/image2.png)

## Task 3: Bind Mount

```bash
# Create a local folder and file
mkdir site
echo "<h1>Hello students</h1>" > site/index.html

# Bind mount the folder into an Nginx container
docker run -d --name nginx-bind -p 8090:80 -v "$(pwd)/site":/usr/share/nginx/html:ro nginx:alpine

# Access the content
curl http://localhost:8090      # Returns: <h1>Hello students</h1>

# Modify the file WITHOUT restarting the container
echo "<h1>Hello students - content updated live!</h1>" > site/index.html
curl http://localhost:8090      # Returns: <h1>Hello students - content updated live!</h1>
```

**What I understood:** A bind mount links a specific folder on my local machine directly into the container. Any edits I make to the local file appear immediately inside the container—there is no need for a rebuild or restart. This feature is incredibly useful during local development.

![Task 3 - bind mount](screenshots/image3.png)

## Task 4: Overlay Network (Research)

**What it is:** An overlay network connects containers running on **different Docker hosts** (different physical servers or virtual machines) so they behave as though they are on a single shared network.

**How it works:** Docker creates a virtual network spanning multiple hosts. It encapsulates the container traffic (typically using VXLAN) and routes it over the physical network between the hosts. This allows a container on Host A to talk to a container on Host B by name, without exposing ports on the host machine. It requires a distributed key-value store or cluster manager, which is provided in practice by **Docker Swarm** (or Kubernetes).

**Use cases:**
- Multi-host container communication within a cluster.
- Docker Swarm services that need to scale containers across numerous nodes.
- Microservices running on different servers that require secure inter-communication.

**Bridge vs Overlay Comparison:**
| | Bridge network | Overlay network |
|---|---|---|
| Scope | Single host | Multiple hosts |
| Use case | Containers on a single machine | Containers deployed across a cluster |
| Needs orchestrator | No | Yes (Swarm/Kubernetes) |

**Example (on a Docker Swarm):**
```bash
docker swarm init
docker network create -d overlay my-overlay
docker service create --name web --network my-overlay nginx
```

## Cleanup commands used
```bash
docker rm -f frontend backend database web-host nginx-bind
docker network rm frontend-net backend-net db-net
```
