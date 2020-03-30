```
systemctl start docker
docker volume create nexus-data
docker volume  ls
docker inspect nexus-data
docker run -d -p 8081:8081 --name nexus --mount source=nexus-data,target=/nexus-data sonatype/nexus3
docker ps
docker exec -it $CONTAINER_ID bash
	PS1='\u@\h \W $ '
	alias l='ls -Ahl --color'
sudo -s
cat /media/veracrypt1/Development/docker/volumes/nexus-data/_data/admin.password
```

