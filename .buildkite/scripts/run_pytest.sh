#!/bin/bash

echo "$BUILDKITE_PARALLEL_JOB"
echo "$BUILDKITE_PARALLEL_JOB_COUNT"

set -euo pipefail
cp -a /upstream /workdir
export HOME=/workdir && cd $HOME && bash .buildkite/scripts/install_bagua.sh || exit 1
upgrade_python() {
    if [ ! -f "/root/Python-3.8.12.tgz" ]; then
        wget -q -nc --no-check-certificate -P /root https://www.python.org/ftp/python/3.8.12/Python-3.8.12.tgz
    fi
    if [ ! -d "/root/Python-3.8.12" ]; then
        tar -xvf /root/Python-3.8.12.tgz -C /root
    fi
    cd /root/Python-3.8.12 && ./configure --enable-optimizations --prefix=/usr && make altinstall && cd -
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1
}

check_python_version() {
    PYTHON_VERSION_OK=$(python3 -c 'import sys; print(int(sys.version_info > (3, 7)))')
    echo ----$PYTHON_VERSION_OK
    if [[ $PYTHON_VERSION_OK -eq 0 ]]; then
         upgrade_python
    fi

}
check_python_version
pip install pytest-timeout
pip install git+https://github.com/PyTorchLightning/pytorch-lightning.git
pytest --timeout=300 -s -o "testpaths=tests"
