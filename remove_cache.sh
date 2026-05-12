#!/bin/bash

pushd /opt/rocm/llvm/bin
if [[ -d original ]]; then
    sudo mv original/clang .;
    sudo mv original/clang++ .;
fi
sudo rm -rf original
popd
sudo rm -rf /opt/cache

