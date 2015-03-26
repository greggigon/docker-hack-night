# Docker Hack Night


## Requirements:

- VirtualBox - the latest version https://www.virtualbox.org/wiki/Downloads
- Vagrant - the latest version https://www.vagrantup.com/downloads.html
-- The installer should add `vagrant` to your path, see http://docs.vagrantup.com/v2/installation/ if you're having trouble.
- ~15 GB Free disk space
- ~2 GB Free memory

Once you've installed VirtualBox and Vagrant do the following:

1. Create a directory, for example 'hacknight'
1. Download all of the files from [here](vagrant/fedora/) to the directory you created.

1. `vagrant up` will download, configure and start the VM according to the instructions in [Vagrantfile](vagrant/fedora/Vagrantfile). **Warning** The VM is almost 3 GB!
1. Virtualbox will start a Fedora 21 VM with everything installed and configured, you should be able to login using the username *vagrant* and password *vagrant*
1. Firefox, a terminal and the Sublime Text text editor are available from the activities menu in the top left.
1. Vagrant will automatically map the current directory on the host to /vagrant in the guest
1. If you prefer, you can ssh to the guest from the host using `vagrant ssh` or as follows: `ssh -p 2222 vagrant@localhost`.  The private key is [here](https://github.com/mitchellh/vagrant/tree/master/keys)
1. `vagrant halt` will shut the VM down

You're now ready to follow the exercises below.

## Exercises

1. [Basics](docs/1. basics/README.md)
1. [Networking](docs/2. networking/README.md)
1. [Linking](docs/3. linking/README.md)
1. [Volumes](docs/4. volumes/README.md)
1. [Building](docs/5. building/README.md)
1. [Clustering](docs/6. clustering/README.md)

