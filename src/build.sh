docker rm -f websafety-config websafety
docker rmi -f johannrichard/websafety:armhf-baseimage-testing 
docker build -t johannrichard/websafety:armhf-baseimage-testing .
