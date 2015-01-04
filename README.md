# Learning Assembly

Going through __Programming From The Ground Up__.

http://mirrors.fe.up.pt/pub/nongnu//pgubook/ProgrammingGroundUp-1-0-booksize.pdf

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
./run <program-name>        # w/o suffixes
```
