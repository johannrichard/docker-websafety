docker rm -f websafety-config websafety
docker rmi -f johannrichard/websafety:armhf-testing 
docker build -t johannrichard/websafety:armhf-testing .
