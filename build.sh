#!/bin/bash

set -ex

if ! command -v mvn &> /dev/null
then
    echo "mvn could not be found, please install maven first"
    exit
else
    mvn_path=`which mvn`
    echo "Using ${mvn_path} for build core module"
fi

CURRENT_DIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
DIST_PATH=${CURRENT_DIR}/dist/

if [ ! -d ${DIST_PATH} ];
then
  mkdir ${DIST_PATH}
fi

BUILD_PYSPARK=${RAYDP_BUILD_PYSPARK:-0}
BUILD_RAY=${RAYDP_BUILD_RAY:-0}

if [ ${BUILD_PYSPARK} == 1 ];
then
  ${CURRENT_DIR}/dev/build_pyspark_with_patch.sh
fi

if [ ${BUILD_RAY} == 1 ];
then
  ${CURRENT_DIR}/dev/build_ray_with_patch.sh
fi

CORE_DIR="${CURRENT_DIR}/core"
pushd ${CORE_DIR}
mvn clean package -q -DskipTests
popd # core dir

PYTHON_DIR="${CURRENT_DIR}/python"
pushd ${PYTHON_DIR}
python setup.py bdist_wheel
cp ${PYTHON_DIR}/dist/raydp-* ${DIST_PATH}
popd # python dir

set +ex
