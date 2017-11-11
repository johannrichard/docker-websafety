docker run -it --name websafety-config johannrichard/docker-websafety:testing /usr/local/bin/firstrun.sh
docker run -dt --name websafety --dns=8.8.8.8 --volumes-from websafety-config -p 8000:80 -p 3128:3128 -p 3127:3127 -p 3126:3126 -p 18999:18999 johannrichard/docker-websafety:testing
