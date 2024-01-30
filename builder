#!/usr/bin/env bash

sourcedir=$1
startdir=`pwd`
rootdir=`dirname "${file}"`
outputdir="${rootdir}/output/"

if [[ -z "${sourcedir}" ]]; then
    echo "usage: ./builder <sourcedir name OR 'all'>"
    exit 1
fi

function build_cimgui() {
    echo "building cimgui..."

    cd "${rootdir}/cimgui"
    rm -rf build
    mkdir build
    cd build

    CMAKE_OSX_ARCHITECTURES="arm64" cmake ..
    make

    cd $startdir
    mv "${rootdir}/cimgui/build/cimgui.dylib" "${outputdir}"
    rm -rf "${rootdir}/cimgui/build"
}

function build_bc7enc() {
    echo "building bc7enc..."

    cd "${rootdir}/bc7enc_rdo"
    rm -rf build
    mkdir build
    cd build

    CMAKE_OSX_ARCHITECTURES="arm64" CXX=g++-13 CC=gcc-13 cmake ..
    make

    cd $startdir
    mv "${rootdir}/bc7enc_rdo/build/bc7enc" "${outputdir}"
    rm -rf "${rootdir}/bc7enc_rdo/build"
}

function build_refreshc() {
    echo "building refreshc..."

    cd "${rootdir}/Refresh/shadercompiler/"
    sed -i '' -e 's/net7.0/net8.0/g' refreshc.csproj
    dotnet build refreshc.csproj

    cd $startdir
    mv "${rootdir}/Refresh/shadercompiler/bin/Debug/net8.0/refreshc" "${outputdir}"

    cd "${rootdir}/Refresh/shadercompiler/"
    rm -rf bin obj
    git co refreshc.csproj
    cd $startdir
}

function build_msdf-atlas-gen() {
    echo "building msdf-atlas-gen..."

    cd "${rootdir}/msdf-atlas-gen"
    rm -rf build
    mkdir build
    cd build

    CMAKE_OSX_ARCHITECTURES="arm64" VCPKG_ROOT="${HOME}/dev/github.com/Microsoft/vcpkg/" cmake ..
    make

    cd $startdir
    mv "${rootdir}/msdf-atlas-gen/build/bin/msdf-atlas-gen" "${outputdir}"
    rm -rf "${rootdir}/msdf-atlas-gen/build"
}

function build_qoaconv() {
    echo "building qoaconv..."

    cd "${rootdir}/qoa"
    gcc qoaconv.c -std=gnu99 -lm -O3 -o qoaconv

    cd $startdir
    mv "${rootdir}/qoa/qoaconv" "${outputdir}"
    rm -rf "${rootdir}/qoa/qoaconv"
}

function build_cramcli() {
    echo "building cramcli..."

    cd "${rootdir}/Cram"
    rm -rf build
    mkdir build
    cd build

    CMAKE_OSX_ARCHITECTURES="arm64" cmake ..
    make

    cd $startdir
    mv "${rootdir}/Cram/build/cramcli" "${outputdir}"
    rm -rf "${rootdir}/Cram/build"
}

case "${sourcedir}" in
    "cimgui")
        build_cimgui
        ;;
    "bc7enc")
        build_bc7enc
        ;;
    "refreshc")
        build_refreshc
        ;;
    "msdf-atlas-gen")
        build_msdf-atlas-gen
        ;;
    "qoaconv")
        build_qoaconv
        ;;
    "cramcli")
        build_cramcli
        ;;
    "all")
        build_cimgui
        build_bc7enc
        build_refreshc
        build_msdf-atlas-gen
        build_qoaconv
        ;;
    *)
        echo "unknown sourcedir ${sourcedir}"
        ;;
esac
