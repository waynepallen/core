#!/bin/bash
install_ruby() {
    zypper -n update
    zypper -n install ruby ruby-devel curl
}
