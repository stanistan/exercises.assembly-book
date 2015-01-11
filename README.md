# Learning Assembly

Going through __[Programming From The Ground Up](http://mirrors.fe.up.pt/pub/nongnu//pgubook/ProgrammingGroundUp-1-0-booksize.pdf)__.

---

#### Initial Setup

I am running all of the exercises in a Ubuntu VM via Vagrant (`precise32`).

1. Get Vagrant [here](https://www.vagrantup.com/downloads) or, if using homebrew:

    ```
    brew cask install virtualbox
    brew cask install vagrant
    ```

2. Get the box

    ```
    vagrant box add precise32 http://files.vagrantup.com/precise32.box
    ```

3. Pick a place to have the vm.

    ```
    cd path/to/proj
    vagran init precise32
    vagrant up

    # I have the project running as shared on the vm.
    git clone git@github.com:stanistan/exercises.assembly-book.git book
    ```

4. Dependencies on the VM (TODO: move to Vagrantfile and actually manage the dependencies)

    ```
    vagrant ssh
    sudo apt-get install make
    sudo apt-get install libc6-dev-i386
    ```

#### `./run`

I'm using this to assemble and my program.

It operates on source files in `src` and sends `.o` and binaries to `build`, which itself
is ignored by git.

```
# on the vm
$> vagrant ssh
$> cd /vagrant/book # or whatever the path is

# assemble:
# will build the object files for all of the inputs
$> ./run assemble read-records read-record count-chars write-newline alloc
  [/vagrant/book/src]: as --32 ./read-records.s -o ../build/read-records.o
  [/vagrant/book/src]: as --32 ./read-record.s -o ../build/read-record.o
  [/vagrant/book/src]: as --32 ./count-chars.s -o ../build/count-chars.o
  [/vagrant/book/src]: as --32 ./write-newline.s -o ../build/write-newline.o
  [/vagrant/book/src]: as --32 ./alloc.s -o ../build/alloc.o

# link:
# will run the linker outputing the binary
# of the first argument
$> ./run link read-records read-record count-chars write-newline alloc
  [/vagrant/book/build]: ld -m elf_i386 read-records.o read-record.o count-chars.o write-newline.o alloc.o -o read-records


# build:
# runs assemble then link on the same args.
$> ./run build read-records read-record count-chars write-newline alloc
  ...

# simple:
# run it, also echoing the exit status.
# the equivalent of ./run build factorial && ./run exec factorial
$> ./run simple factorial
  [/vagrant/book/src]: as --32 ./factorial.s -o ../build/factorial.o
  [/vagrant/book/build]: ld -m elf_i386 factorial.o  -o factorial
  EXIT STATUS: 24
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

### Noticed errata

... Need to add things here from earlier portions of the book.

###### Chapter 10

- Page `204` - [DAV's Endian FAQ](http://david.carybros.com/html/endian_faq.html) - the URL in the book is no longer active.
