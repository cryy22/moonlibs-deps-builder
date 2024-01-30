#!/usr/bin/env bash

library=$1
startdir=`pwd`
rootdir=`dirname "${file}"`

if [[ -z "${library}" ]]; then
    echo "usage: ./builder <library name OR 'all'>"
    exit 1
fi

function build_cimgui() {
    echo "building cimgui..."

    cd "${rootdir}/cimgui"
    rm -rf build
    mkdir build
    cd build

    CMAKE_OSX_ARCHITECTURES="x86_64;arm64" cmake ..
    make

    cd $startdir
    mv "${rootdir}/cimgui/build/cimgui.dylib" "${rootdir}/libs/"
}


case "${library}" in
    "cimgui")
        build_cimgui
        ;;
    *)
        echo "unknown library ${library}"
        ;;
esac
