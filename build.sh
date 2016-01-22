docker -H 127.0.0.1:2375 build --tag rpheuts/arch-surface .
docker -H 127.0.0.1:2375 run --privileged -v `pwd`:/work/ rpheuts/arch-surface
