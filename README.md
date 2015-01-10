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
