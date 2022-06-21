# ClamAV

Taken from https://docs.clamav.net/manual/Installing/Docker.html

```bash
# Update Podman file locations
vi ~/.local/share/containers/

# Create a Volume
podman volume create clamav
podman volume inspect clamav

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
podman run \
--mount type=volume,src=clamav,target=/var/lib/clamav \
--mount type=bind,scr=/home/dallas/Development/containers-and-orchestration/podman/clamav/scandir,target=/scandir
--interactive \
--tty \
--rm \
--name "clamav_container" \
clamav/clamav:latest_base
```

