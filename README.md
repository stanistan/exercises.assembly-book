# Learning Assembly

Going through __[Programming From The Ground Up](http://mirrors.fe.up.pt/pub/nongnu//pgubook/ProgrammingGroundUp-1-0-booksize.pdf)__.

---

### How to run things

__Get Vagrant__

```
vagrant box add precise32 http://files.vagrantup.com/precise32.box
vagrant init precise32
vagrant up

# now we can run some scripts
# if the Vagrantfile is in the root repo
vagrant ssh
sudo apt-get install make               # cause Makefile
sudo apt-get install libc6-dev-i386     # cause we need to link to this later

# in the machine
cd /vagrant/<repo-name>     # these are shared

# w/o suffixes for a simple program.
# the equivalent of
# ./run build factorial && ./run exec factorial
./run simple factorial

# for linking multiple things
# this will end up building the executable with the name thing1
# in ./build
./run build thing1 thing2 thing3
./run exec thing1 # arg1 arg2 arg3 ... as necessary
```

### Dependencies and weirdness

The book itself & all of its examples are on a 32bit runtime, so given my own
ignorance and wanting to continue moving through it on a 64bit vm (maybe this was a
problem overall), requires some patching.

__Assembling__

```
as --32 foo.s -o foo.o
```

__Linking__

```
ld -m elf_i386 foo.o -o foo
```
