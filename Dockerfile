# specifies the base image to use
FROM node:18-alpine            
# sets the working directory for any RUN, CMD, ENTRYPOINT, COPY and ADD instructions that follow it in the Dockerfile
WORKDIR /app                   
# copies this application into the container 
COPY . .                      
# install dependencies 
RUN yarn install --production 
# directive specifies the default command to run when the container starts
CMD ["node", "src/index.js"]   
