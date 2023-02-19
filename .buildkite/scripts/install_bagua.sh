#!/usr/bin/env bash

echo "$BUILDKITE_PARALLEL_JOB"
echo "$BUILDKITE_PARALLEL_JOB_COUNT"

set -euox pipefail
echo ----0----install_bagua
pwd
whoami
ls -la
if [ -d ./bagua/ ]; then
    ls -la ./bagua/
fi
pip list | grep bagua || echo no bagua found
echo ----2----install_bagua
pip uninstall -y bagua bagua-core
export HOME=/workdir && cd $HOME
echo ---1---$HOME
curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable -y
echo ---2---$HOME
source $HOME/.cargo/env
# cd /workdir && python3 -m pip install --force-reinstall --no-cache-dir . || exit 1
git config --global --add safe.directory /workdir/rust/bagua-core/bagua-core-internal/third_party/Aluminum
cd /workdir && python3 setup.py install -f || exit 1
ls -la
echo ----3----install_bagua
pwd
whoami
ls -la
if [ -d ./bagua/ ]; then
    ls -la ./bagua/
fi
pip list | grep bagua || echo no bagua found
rm -rf bagua bagua_core
echo ----4----install_bagua
pwd
whoami
ls -la
if [ -d ./bagua/ ]; then
    ls -la ./bagua/
fi
pip list | grep bagua || echo no bagua found
echo ----5----install_bagua
