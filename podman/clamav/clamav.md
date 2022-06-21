# ClamAV

Taken from https://docs.clamav.net/manual/Installing/Docker.html

```bash
# Update Podman file locations
vi ~/.local/share/containers/

# Create a Volume for the app and the scanning directory.
# The inspect command can be used to find the absoluate path on the CRE host.
podman volume create clamav
podman volume inspect clamav
podman volume create clmansv_scandir
podman volume inspect clamav_scandir


# Run the container
# Can use -it instead of --tty & --interactive
podman run \
--mount type=volume,src=clamav,target=/var/lib/clamav \
--interactive \
--tty \
--rm \
--name "clamav_container" \
clamav/clamav:latest_base

# Run the container with a scandir mounted
# Use --volume to create the bind path inside the container, --mount doesn't do this. But you still have to deal with file system permissions between the CRE host and the container. https://docs.docker.com/storage/bind-mounts/#differences-between--v-and---mount-behavior
podman run \
--mount type=volume,src=clamav,target=/var/lib/clamav \
--volume /home/dallas/Development/containers-and-orchestration/podman/clamav/scandir:/scandir \
--interactive \
--tty \
--rm \
--name "clamav_container" \
clamav/clamav:latest_base

# Run the container with a scandir mounted and do a scan
podman run \
--mount type=volume,src=clamav,dst=/var/lib/clamav \
--mount type=volume,src=clamav_scandir,dst=/scandir \
--interactive \
--tty \
--rm \
--name "clamav_container" \
clamav/clamav:latest_base \
clamscan /scandir
```

