docker start RVOS

echo "Enter container: RVOS"
docker exec \
    -u root \
    -it RVOS \
    /bin/bash
