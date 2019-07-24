#!/bin/bash

generate_seed() {
    dd count=1 bs=8 if=/dev/urandom 2>/dev/null | od -A n -t d8
}

generate_seed
