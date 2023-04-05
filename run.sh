zig build

git clone https://github.com/limine-bootloader/limine.git --branch=v4.x-branch-binary --depth=1
make -C limine

rm -rf iso_root
mkdir -p iso_root
cp zig-out/bin/arachne.elf \
    config/limine.cfg limine/limine.sys limine/limine-cd.bin limine/limine-cd-efi.bin iso_root/
xorriso -as mkisofs -b limine-cd.bin \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    --efi-boot limine-cd-efi.bin \
    -efi-boot-part --efi-boot-image --protective-msdos-label \
    iso_root -o arachne.iso
limine/limine-deploy arachne.iso
rm -rf iso_root

qemu-system-x86_64 \
    -M q35 \
    -m 2G \
    -bios ovmf/OVMF.fd \
    -cdrom arachne.iso \
    -boot d \
    -d int,guest_errors \
    -D debug.log \
    -no-reboot \
    -no-shutdown