#!/bin/bash

function oneTimeSetUp() {
	$HOMESHICK_BIN --batch clone $REPO_FIXTURES/deep-files > /dev/null
	mkdir -p $HOME/.config/bar.dir
	cat > $HOME/.config/foo.conf <<EOF
#I am just a regular foo.conf file 
[foo]
A=True
EOF
	cat > $HOME/.config/bar.dir/bar.conf <<EOF
#I am just a regular bar.conf file 
[bar]
A=True
EOF
}

function testDeepLinking() {
	assertTrue "The .config/foo.conf file did not exist before symlinking" "[ -f $HOME/.config/foo.conf ]"
	#.config/foo.conf should be overwritten by a directory of the same name
	assertTrue "The .config/bar.dir/ directory did not exist before symlinking" "[ -d $HOME/.config/bar.dir ]"
	#.config/bar.dir should be overwritten by a file of the same name
	$HOMESHICK_BIN --batch --force link deep-files > /dev/null
	assertTrue "'link' did not symlink the .config/foo.conf directory" "[ -d $HOME/.config/foo.conf ]"
	assertTrue "'link' did not symlink the .config/bar.dir directory" "[ -f $HOME/.config/bar.dir ]"
}

function testLegacySymlinks() {
	assertTrue "known_hosts file does not exist" "[ -e $HOME/.ssh/known_hosts ]"
	rm -rf "$HOME/.ssh"
	# Recreate the legacy scenario
	ln -s $HOMESICK/repos/deep-files/home/.ssh $HOME/.ssh
	$HOMESHICK_BIN --batch --force link deep-files > /dev/null
	# Without legacy handling if we were to run `file $HOME/.ssh/known_hosts` we would get
	# .ssh/known_hosts: symbolic link in a loop
	# The `test -e` is sufficient though
	assertTrue "known_hosts file is a symbolic loop or does not exist" "[ -e $HOME/.ssh/known_hosts ]"
}

function oneTimeTearDown() {
	rm -rf "$HOMESICK/repos/deep-files"
	find "$HOME" -mindepth 1 -not -name '.homesick' -not -name '.homeshick' -not -name '.gitconfig' -delete 
}

source $SHUNIT2
