#!/bin/bash
install_prereqs() {
    zypper -n update
    zypper -n install curl
}
