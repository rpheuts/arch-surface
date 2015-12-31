# Arch-Surface

These are tools for building a custom live-iso for Arch Linux. It's using the Arch Docker image (rpheuts/archlinux) to build the live environment using the 'archiso' tool. The main feature here is the ability to swap out the kernel and auto-patch the new kernel. It will download the kernel sources, apply the patches and then inject them into the live-iso before it is built. I'm mainly using it for testing different kernels quickly on the Microsoft Surface Book, but you can use this setup to build any live-iso you want. 
