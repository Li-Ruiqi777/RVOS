# 创建新容器
echo "start a new container : RVOS"

docker run -it -d \
--name RVOS \
-v /home/jiahan/Desktop/RVOS:/workspace \
--net host \
dockerpull.org/ubuntu:20.04