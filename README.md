# Docker Hack Night


## Requirements:

- VirtualBox - the latest version https://www.virtualbox.org/wiki/Downloads
- Vagrant - the latest version https://www.vagrantup.com/downloads.html
-- The installer should add `vagrant` to your path, see http://docs.vagrantup.com/v2/installation/ if you're having trouble.
- ~15 GB Free disk space
- ~2 GB Free memory

Once you've installed VirtualBox and Vagrant do the following:

1. Download and extract the GitHub Repo https://github.com/greggigon/docker-hack-night/archive/master.zip
2. In your command prompt change to the vagrant/deephack directory from the extracted zip
3. Run `vagrant up` in a command prompt.  This will download, configure and start the VM according to the instructions in [Vagrantfile](vagrant/deephack/Vagrantfile). **Warning** The VM is almost 1.5 GB!
4. Virtualbox will start a Fedora 21 VM with everything installed and configured, you should be able to login using the username *vagrant* and password *vagrant*
5. Firefox, a terminal and the Sublime Text text editor are available from the panel at the bottom
6. Vagrant will automatically map the current directory on the host to /vagrant in the guest
7. If you prefer, you can ssh to the guest from the host using `vagrant ssh` or as follows: `ssh -p 2222 vagrant@localhost`.  The private key is [here](https://github.com/mitchellh/vagrant/tree/master/keys)
8. `vagrant halt` will shut the VM down

You're now ready to follow the exercises below.

## Exercises

1. [Basics](docs/1. basics/README.md)
2. [Networking](docs/2. networking/README.md)
3. [Linking](docs/3. linking/README.md)
4. [Volumes](docs/4. volumes/README.md)
5. [Building](docs/5. building/README.md)
6. [Clustering](docs/6. clustering/README.md)


### Some links

[Docker](https://docker.io)

[Markdown editor in Browser, Stackedit](http://localhost:9000/#/kanban/Test%20ban)

[Kubernetes](https://github.com/googlecloudplatform/kubernetes)

[OpenShift](https://github.com/openshift/origin)

Docker Security: http://opensource.com/business/14/7/docker-security-selinux, http://opensource.com/business/15/3/docker-security-future
