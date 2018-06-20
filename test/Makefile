BOX_NAME=me/Win10LTSB_x64

all: test

test: test-boot test-flag test-bootstrap test-sync test-shutdown

test-boot:
	vagrant up

test-flag:
	vagrant ssh --no-tty -c "cat ~/flag.txt | grep \"all ur base are belong to us\""

test-bootstrap:
	vagrant ssh --no-tty -c "curl.exe --version"

test-sync: test-sync-host-to-guest test-sync-guest-to-host

test-sync-host-to-guest:
	echo "hello" > greeting.txt
	vagrant rsync
	vagrant ssh --no-tty -c "cat /vagrant/greeting.txt | grep -- \"hello\""

test-sync-guest-to-host:
	vagrant ssh --no-tty -c "echo howdy | tee /vagrant/greeting.txt"
	vagrant rsync-back
	cat greeting.txt | grep howdy

test-shutdown:
	vagrant halt

clean-greeting:
	-rm -f greeting.txt

clean-vm:
	-vagrant destroy -f

clean-boxes:
	-rm -rf *.box

clean-vagrant-metadata:
	-rm -rf .vagrant

clean: clean-greeting clean-vm clean-boxes clean-vagrant-metadata

.PHONY: test test-boot test-flag test-bootstrap test-sync test-shutdown
.PHONY: clean-greeting clean-vm clean-boxes clean-vagrant-metadata

