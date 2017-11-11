docker rm -f websafety-config websafety
docker rmi -f johannrichard/websafety:armhf-testing 
docker build --force-rm --no-cache --rm=true -t johannrichard/websafety:armhf-testing .
