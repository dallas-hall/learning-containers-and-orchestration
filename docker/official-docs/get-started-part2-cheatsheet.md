```
# Create image using this directory's Dockerfile
docker build -t friendly-hello .

# Run "friendlyname" image and  map HOST port 4000 to CONTAINER port 80
docker run -p 4000:80 friendly-hello

# Same thing, but in detached mode (i.e. in the background)
docker run -d -p 4000:80 friendly-hello

# List running containers
docker container ls

# List all containers, even those not running
docker container ls -a

# Gracefully stop the specified container
docker container stop $CONTAINER_NAME_OR_ID

# Force shutdown of the specified container
docker container kill $CONTAINER_NAME_OR_ID

# Remove specified container from this machine. Can just use docker rm instead.
docker container rm $CONTAINER_NAME_OR_ID

# Remove all containers. -a lists all and -q lists IDs only
docker container rm $(docker container ls -a -q)

# List all images on this machine
docker images

# Remove specified image from this machine. Can just use docker rmi instead.
docker image rm $IMAGE_NAME_OR_ID

# Remove all images from this machine. -a lists all and -q lists IDs only
docker image rm $(docker image ls -a -q)

# Log in this CLI session using your Docker credentials
docker login

# Tag an image for upload to registry
docker tag $IMAGE_NAME_OR_ID username/repository:tag

# Upload tagged image to registry
docker push username/repository:tag

# Run image from a registry
docker run username/repository:tag
```
