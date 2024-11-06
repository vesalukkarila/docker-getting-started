# docker-getting-started

## build image from Dockerfile
```docker build -t getting-started .```  
t = tags the image  
. = docker should look for Dockerfile in this folder.

 ## run the image in container
 ```docker run -d -p 3000:3000 getting-started```  
d = detached mode, runs in backround  
p = hostport:containerport