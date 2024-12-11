# 停止并删除同名容器
echo "stop and rm docker" 
docker stop RVOS > /dev/null
docker rm -v -f RVOS
