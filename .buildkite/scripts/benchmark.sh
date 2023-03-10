#!/usr/bin/env bash

echo "$BUILDKITE_PARALLEL_JOB"
echo "$BUILDKITE_PARALLEL_JOB_COUNT"

set -euox pipefail
echo ------benchmark----0
pwd
whoami
echo ---$HOME--
ls -la
if [ -d ./bagua/ ]; then
    ls -la ./bagua/
fi
pip list | grep bagua
echo ------benchmark----1

cp -a /upstream /workdir

export HOME=/workdir && cd $HOME && bash .buildkite/scripts/install_bagua.sh || exit 1

echo ------benchmark----2
pwd
whoami
echo ---$HOME--
ls -la
if [ -d ./bagua/ ]; then
    ls -la ./bagua/
fi
pip list | grep bagua
echo ------benchmark----3
SYNTHETIC_SCRIPT="examples/benchmark/synthetic_benchmark.py"

function check_benchmark_log {
    logfile=$1

    final_img_per_sec=$(cat ${logfile} | grep "Img/sec per " | tail -n 1 | awk '{print $6}')
    threshold="70.0"

    python -c "import sys; sys.exit(0 if float($final_img_per_sec) > float($threshold) else 1)"
}

logfile=$(mktemp /tmp/bagua_benchmark.XXXXXX.log)
python -m bagua.distributed.run \
    --standalone \
    --nnodes=1 \
    --nproc_per_node 1 \
    --no_python \
    --autotune_level 1 \
    --default_bucket_size 2147483648 \
    --autotune_warmup_time 10 \
    --autotune_max_samples 30 \
    python ${SYNTHETIC_SCRIPT} \
    --num-iters 200 \
    --model vgg16 \
    2>&1 | tee ${logfile}
check_benchmark_log ${logfile}
