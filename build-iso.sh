KERNEL="4.3.3"
KERNEL_STABLE="true"

mkdir work
pushd work

if [[ ${KERNEL_STABLE} = "true" ]]
then
	wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-${KERNEL}.tar.gz
else
	wget https://cdn.kernel.org/pub/linux/kernel/v4.x/testing/linux-${KERNEL}.tar.gz
fi

tar -xvf linux-${KERNEL}.tar.gz

pushd linux-${KERNEL}
patch -p1 < ../../patches/${KERNEL}/*

cp ../../configs/default/.config ./

yes "" | make oldconfig

make -j4
