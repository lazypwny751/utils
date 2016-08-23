#!/bin/bash

# warn people with this.

warn() {
	echo >&2 "$*"
}

# kill if necessary.

die() {
	warn "$*"
    exit 1
}

main() {

}


