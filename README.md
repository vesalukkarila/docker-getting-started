# docker-getting-started

## build image from Dockerfile
```docker build -t getting-started .```  
t = tags the image  
. = docker should look for Dockerfile in this folder.

 ## run the image in container
 ```docker run -d -p 3000:3000 getting-started```  
-d = detached mode, runs in backround  
-p = hostport:containerport

## Commands
```docker ps```, shows running containers  
```docker ps -a --filter "status=exited"```, -a shows running and stopped containers, -filter stopped (exited state = stopped)  
```docker images```, shows existing images  
```docker stop <container_name_or_id> ```+```docker rm <container_name_or_id>```: Gracefully stops a container, then removes it.  
```docker kill <container_name_or_id>```+```docker rm <container_name_or_id>```: Abruptly kills a container, then removes it (useful for unresponsive containers).  
```docker stop $(docker ps -q)```, docker ps -q lists the IDs of all running containers.  
```docker logs <container-id>```, logs for container  
```docker exec [OPTIONS] container commands [arg]```, allows to execute commands in container without stopping or restarting it
### push to docker hub registry
- the image needs to tagged as ```username/imagename[:tag]```, where username is Docker Hub username.  
- to avoid re-tagging, the image should be tagged correctly when building the image from Dockerfile.  
```docker tag imagename vesalukkarila/imagename:latest```
- push to docker hub registry  
```docker push vesalukkarila/imagename:latest```

### Play with docker
Once image is pushed to registry, one can also run it here:  
https://labs.play-with-docker.com/

## Named Volume
Persists data on host system, even if container itself is stopped and removed. 
The volume is outside the container, on the host machine in a Docker managed location.  
- Create and name the volume:  
```docker volume create todo-db```  

The volume (from the host system) is mounted to /etc/todos (path inside the container) with -v flag
- any data read from or written to this path is saved in the volume on the host
- every new container needs to be started with the same ```-v ...``` configuration to give access to the same data  
```docker run -dp 3000:3000 -v todo-db:/etc/todos getting-started```  

To inspect where the volume actually is:
```docker volume inspect```

## Bind mounts
(return to this with Java)  
With bind mounts, we control the exact mountpoint on the host.  
We can use this to persist data, but is often used to provide additional data into containers.  
When working on an application, we can use a bind mount to mount our source code into the container to let it 
see code changes, respond, and let us see the changes right away.  
**i.e. changes to the code on the host will be 
reflected inside the container in real-time**    

In the tutorial:  
Mount source code into the container  
Install all dependencies, including the "dev" depenedencies  
Start nodemon to watch for filesystem changes  
- -w /app - sets the container's present working directory where the command will run from
- -v "$(pwd):/app" - bind mount (link) the host's present getting-started/app directory to the container's /app directory. Note: Docker requires absolute paths for binding mounts, so in this example we use pwd for printing the absolute path of the working directory, i.e. the app directory, instead of typing it manually
```
docker run -dp 3000:3000 \
    -w /app -v "$(pwd):/app" \
    node:18-alpine \
    sh -c "yarn install && yarn run dev"
  ```   
More general example:  
```docker run -v /path/to/your/source:/path/in/container my-image```

## Multi-Container Apps
### CLI way
If two containers are on the same network, they can talk to each other. If they aren't, they can't.  

Creating a custom Docker network. Allows containers to communicate over dedicated network.  
```docker network create <network_name>```, network-name=todo-app in tutorial

--network todo-app, connects the container (run from the image mysql:8.0) to network  
--network-alias mysql, sets alias for the container on the todo-app network  
-v todo-mysql-data:/var/lib/mysql, named volume for data persistance
-e MYSQL_ROOT_PASSWORD=secret: Sets the root password for MySQL to secret, required for MySQL setup  
-e MYSQL_DATABASE=todos: Creates a new database named todos automatically when the container starts  
```
docker run -d \
    --network todo-app --network-alias mysql \
    -v todo-mysql-data:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=secret \
    -e MYSQL_DATABASE=todos \
    mysql:8.0
   ``` 
    

nicolaka/netshoot container, which has a lot of tools, can be used to troubleshooting and debuggin networking issues.  
```docker run -it --network todo-app nicolaka/netshoot```  
dig is a DNS tool, will show ip-address of the hostname mysql  
```dig mysql``` 

Connecting our app to network and inside that to the container holding previously created database.

```docker run -dp 3000:3000 \
  -w /app -v "$(pwd):/app" \
  --network todo-app \
  -e MYSQL_HOST=mysql \
  -e MYSQL_USER=root \
  -e MYSQL_PASSWORD=secret \
  -e MYSQL_DB=todos \
  vesalukkarila/getting-started  \
  sh -c "yarn install && yarn run dev"
  ```

### Docker Compose way, the easier one
- See heavily annotated docker-compose.yml

```docker compose up -d```, detached runs in the background    
```docker compose logs -f```, follows, gives live output
```docker compose down```, shutdown and network removed, volumes are kept


## Image Building Best Practices  
```docker scan <imagename>```, scan vulnerabilities    
```docker image history <imagename>```, see commands that were used to create each layer within an image    

### Caching layers  
See updated Dockerfile, .dockerignore added.  

### Multi-stage builds
Separate build-time dependencies from runtime dependencies.  
Reduce overall image size by shipping only what your app needs to run.

In  short:  
- JDK and Maven are used only in build stage to compile and create .jar
- By separating build and runtime stage the final image size will be reduced, by excluding unnecessary dependencies(JDK, Maven..)  
- Final image is only the last stage being created, including only the runtime environment and the application artifact(.jar)  
```
# Build stage
FROM maven:3.8.1-jdk-11 AS build
WORKDIR /app
COPY . .
RUN mvn clean package

# Runtime stage
FROM openjdk:11-jre-slim
WORKDIR /app
COPY --from=build /app/target/myapp.jar /app/myapp.jar
CMD ["java", "-jar", "/app/myapp.jar"]
```  