# mjk

I'm having a go at writing a kernel in C for learning and fun.

## Rough Plan

1. To target Rasperry Pi so that I can actually us the raspberry pi that I was given as a present years ago...
2. To also target x86 also so I cna understand the principles of kernel development vs the architecture specific implementations.
3. If I get some functionality going it might be fun to do some [Coding Challenges](https://codingchallenges.fyi/challenges/intro) by implementing them in my kernel.
4. I'll follow POSIX standards and Linux design principles so I don't have to do too much hard thinking about design, I want to focus more on the coding.
5. I'll try and TDD it as much as possible.
6. I'll add lots of docs and comments to record my understanding and help anyone else (who is unfamiliar with kernel development) who wants to learn.

## Getting started

Note: I am developing this on **Windows with WSL2** (Ubuntu) but it should work the same on a real Linux box.

The following packages are required to build and run:
- make
- qemu-system-arm
- gcc-aarch64-linux-gnu

You can install them by running:

```bash
sudo apt update
sudo apt install -y make qemu-system-arm gcc-aarch64-linux-gnu
```

After that you should be able to run the kernel by doing:
```bash
make run
```