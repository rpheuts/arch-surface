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

echo Configuring ${KERNEL} kernel...
yes "" | make oldconfig

echo Building ${KERNEL} kernel and modules...
make -j2
make modules_install

popd

mkdir archiso
cp -r /usr/share/archiso/configs/baseline/* ./archiso/
cp packages.x86_64 ./archiso/

##### BUILD ISO ######

pushd archiso

set -e -u

iso_name=archlinux
iso_label="ARCH_$(date +%Y%m)"
iso_version=$(date +%Y.%m.%d)
install_dir=arch
arch=$(uname -m)
work_dir=work
out_dir=out

script_path=$(readlink -f ${0%/*})

mkarchiso -v -w "${work_dir}" -D "${install_dir}" init

cp ../linux-4.3.3/arch/x86_64/boot/bzImage work/airootfs/boot/vmlinuz-linux
cp -r /lib/modules/* work/airootfs/lib/modules/

mkdir -p ${work_dir}/airootfs/etc/initcpio/hooks
mkdir -p ${work_dir}/airootfs/etc/initcpio/install
cp /usr/lib/initcpio/hooks/archiso ${work_dir}/airootfs/etc/initcpio/hooks
cp /usr/lib/initcpio/install/archiso ${work_dir}/airootfs/etc/initcpio/install
cp ${script_path}/mkinitcpio.conf ${work_dir}/airootfs/etc/mkinitcpio-archiso.conf
mkarchiso -v -w "${work_dir}" -D "${install_dir}" -r 'mkinitcpio -c /etc/mkinitcpio-archiso.conf -k /boot/vmlinuz$

mkdir -p ${work_dir}/iso/${install_dir}/boot/${arch}
cp ${work_dir}/airootfs/boot/archiso.img ${work_dir}/iso/${install_dir}/boot/${arch}/archiso.img
cp ${work_dir}/airootfs/boot/vmlinuz-linux ${work_dir}/iso/${install_dir}/boot/${arch}/vmlinuz

mkdir -p ${work_dir}/iso/${install_dir}/boot/syslinux
sed "s|%ARCHISO_LABEL%|${iso_label}|g;
     s|%INSTALL_DIR%|${install_dir}|g;
     s|%ARCH%|${arch}|g" ${script_path}/syslinux/syslinux.cfg > ${work_dir}/iso/${install_dir}/boot/syslinux/sysl$
cp ${work_dir}/airootfs/usr/lib/syslinux/bios/ldlinux.c32 ${work_dir}/iso/${install_dir}/boot/syslinux/
cp ${work_dir}/airootfs/usr/lib/syslinux/bios/menu.c32 ${work_dir}/iso/${install_dir}/boot/syslinux/
cp ${work_dir}/airootfs/usr/lib/syslinux/bios/libutil.c32 ${work_dir}/iso/${install_dir}/boot/syslinux/

mkdir -p ${work_dir}/iso/isolinux
sed "s|%INSTALL_DIR%|${install_dir}|g" ${script_path}/isolinux/isolinux.cfg > ${work_dir}/iso/isolinux/isolinux.c$
cp ${work_dir}/airootfs/usr/lib/syslinux/bios/isolinux.bin ${work_dir}/iso/isolinux/
cp ${work_dir}/airootfs/usr/lib/syslinux/bios/isohdpfx.bin ${work_dir}/iso/isolinux/
cp ${work_dir}/airootfs/usr/lib/syslinux/bios/ldlinux.c32 ${work_dir}/iso/isolinux/

mkarchiso -v -w "${work_dir}" -D "${install_dir}" prepare
mkarchiso -v -w "${work_dir}" -D "${install_dir}" -L "${iso_label}" -o "${out_dir}" iso "${iso_name}-${iso_version}-${arch}.iso"
