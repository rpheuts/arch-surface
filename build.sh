docker build --tag rpheuts/arch-surface .
docker run --privileged -v `pwd`:/work/ rpheuts/arch-surface
