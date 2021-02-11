docker run --restart unless-stopped --detach --name watchtower -v ~/.docker/config.json -v /var/run/docker.sock:/var/run/docker.sock v2tec/watchtower:armhf-latest  --cleanup --interval 30
