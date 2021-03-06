#!/bin/bash

# rt12 -- This runs in docker, so has no access to anything out in the CI

set -e
set -x

# Install a system package required by our library
yum install -y pkg-config libffi libffi-devel

# Use updated GMP
curl -O https://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.bz2 && tar -xjpf gmp-*.tar.bz2 && cd gmp* && ./configure --build=${BUILD_GMP_CPU}-pc-linux-gnu > /dev/null && make > /dev/null && make check > /dev/null && make install > /dev/null && cd ..

mkdir out

# Compile wheels
for PYBIN in /opt/python/*/bin; do
	if [[ ${PYBIN} =~ (cp36|cp37) ]]; then
        echo Building for: ${PYBIN}
	    ${PYBIN}/pip wheel /io/ -w wheelhouse/
        # rm -rf /io/dist/*
    fi
done

ls -l wheelhouse

# Adjust wheel tags
for whl in wheelhouse/electrumsv_secp256k1*.whl; do
    auditwheel -v repair $whl -w out
done

echo wheelhouse directory
ls -l wheelhouse

echo dist directory contents
ls -l /io/dist
cp out/*.whl /io/dist
