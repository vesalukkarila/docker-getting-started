# docker-getting-started

## build image from Dockerfile
```docker build -t getting-started .```  
t = tags the image  
. = docker should look for Dockerfile in this folder.

 ## run the image in container
 ```docker run -d -p 3000:3000 getting-started```  
d = detached mode, runs in backround  
p = hostport:containerport


## stop, rm, kill
- docker stop + docker rm: Gracefully stops a container, then removes it.
- docker kill + docker rm: Abruptly kills a container, then removes it (useful for unresponsive containers).