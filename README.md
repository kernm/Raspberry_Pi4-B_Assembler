# Raspberry_Pi4-B_Assembler
Bare Metal coding with Assembly language on a Raspberry Pi 4 Model B

## Where the magic is happening
Everything you need to know or change is in the "./blink_sos/boot.S" file.

## How to create the Image on Debian
1. `apt install git make gcc-aarch64-linux-gnu`
3. Clone the repo
4. change into the blink_sos folder
5. `make`
6. The output should look like this:
```
aarch64-linux-gnu-gcc -Wall -Wextra -nostdinc -nostdlib -fno-builtin -c -Iinclude -o boot.o boot.S
aarch64-linux-gnu-ld -o kernel.elf boot.o -Map System.map -s -T sys.ld -x
aarch64-linux-gnu-objcopy -O binary kernel.elf kernel8.img
```
8. Copy the "kernel8.img" onto your microSD among the other files in the boot partition
9. Insert the microSD into the RPi4 and give it some power
10. cross your fingers and hope it doesn't explode

## GPIO Pin
In this example I use GPIO-Pin: 24 (PIN 18)

## GPIO Pinout Raspberry Pi 4 Model B
![image](https://user-images.githubusercontent.com/16921197/193692633-cc902dd9-8fec-4a7b-8da9-2976f49ef299.png)
