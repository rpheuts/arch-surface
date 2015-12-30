KERNEL="4.3.3"
KERNEL_STABLE="true"

if [[ ! -d /work ]]
then
	mkdir /work
fi

pushd /work

if [[ ! -d linux-${KERNEL} ]]
then
	if [[ ${KERNEL_STABLE} = "true" ]]
	then
		wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-${KERNEL}.tar.gz
	else
		wget https://cdn.kernel.org/pub/linux/kernel/v4.x/testing/linux-${KERNEL}.tar.gz
	fi

	tar -xvf linux-${KERNEL}.tar.gz
fi

pushd linux-${KERNEL}
cat ../patches/${KERNEL}/* | patch -p1 --forward

if [[ -s ../configs/${KERNEL}/.config ]]
then
	echo "Copying config for kernel: ${KERNEL}"
	cp ../configs/${KERNEL}/.config ./
else
	echo "Copying config for default kernel"
	cp ../configs/default/.config ./
fi

yes "" | make oldconfig

make -j2
