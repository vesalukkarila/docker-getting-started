## specifies the base image to use
#FROM node:18-alpine
## sets the working directory for any RUN, CMD, ENTRYPOINT, COPY and ADD instructions that follow it in the Dockerfile
#WORKDIR /app
## copies this application into the container
#COPY . .
## install dependencies
#RUN yarn install --production
## directive specifies the default command to run when the container starts
#CMD ["node", "src/index.js"]

# in updated version first dependencies are installed, then copy everything else.
FROM node:18-alpine
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --production
COPY . .
CMD ["node", "src/index.js"]