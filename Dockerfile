FROM rpheuts/archlinux

RUN mkdir /run/shm
RUN mkdir /work

RUN pacman -S --noconfirm archiso
RUN pacman -S --noconfirm expect
RUN pacman -S --noconfirm base-devel
RUN pacman -S --noconfirm wget bc

WORKDIR /work/

ENTRYPOINT exec /work/build-iso.sh
