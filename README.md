# docker-getting-started

## build image from Dockerfile
```docker build -t getting-started .```  
t = tags the image  
. = docker should look for Dockerfile in this folder.

 ## run the image in container
 ```docker run -d -p 3000:3000 getting-started```  
d = detached mode, runs in backround  
p = hostport:containerport

## Commands
```docker ps```  
```docker images```
### stop, rm, kill
- docker stop + docker rm: Gracefully stops a container, then removes it.
- docker kill + docker rm: Abruptly kills a container, then removes it (useful for unresponsive containers).

### push to docker hub registry
- the image needs to tagged as "username/image-name" so that docker knows where to push the image  
- to avoid re-tagging, the image should be tagged correctly when building the image from Dockerfile  
```docker tag <imagename> vesalukkarila/<imagename>:latest```
- push to docker hub registry  
```docker push vesalukkarila/<imagename>:latest```

## Play with docker
Once image is pushed to registry, one can also run it here:  
https://labs.play-with-docker.com/

### Named Volume
Persists data on host system, even if container itself is stopped and removed. 
The volume is outside the container, on the host machine in a Docker managed location.  
- Create and name the volume:  
```docker volume create todo-db```  

Here the volume (from the host system) is mounted to /etc/todos (path inside the container) with -v flag
- any data read from or written to this path is saved in the volume on the host
- every new container needs to be started with the same ```-v ...``` configuration to give access to the same data  
```docker run -dp 3000:3000 -v todo-db:/etc/todos getting-started```  

To inspect where the volume actually is:
```docker volume inspect```

### Bind mounts
(return to this with Java)  
With bind mounts, we control the exact mountpoint on the host.  
We can use this to persist data, but is often used to provide additional data into containers.  
When working on an application, **we can use a bind mount to mount our source code into the container to let it see code changes, respond, and let us see the changes right away.**  

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

