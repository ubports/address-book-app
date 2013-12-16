Building for click
==================

To build for a click package configure cmake as:

mkdir build
cd build
cmake [path_to_this_location] -DCLICK_MODE=on \
    -DBZR_REVNO=$(cd [path_to_this_location]; bzr revno)
make DESTDIR=package install
click build package

This package can be installed by running:

pkcon install-local com.ubuntu.address-book_*.click
