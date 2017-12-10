#Building for desktop

    mkdir build
    cd build
    cmake ..
    make

#Run
##on desktop

    cd build
    ./src/app/address-book-app

##the QML tests

    cd build
    make test or ctest 

##the Autopilot tests

    cd build
    make autopilot

#Building for click

To build for a click package configure cmake as:

    mkdir build
    cd build
    cmake [path_to_this_location] -DCLICK_MODE=on \
        -DBZR_REVNO=$(cd [path_to_this_location]; bzr revno)
    make DESTDIR=[package dir] install
    click build [package dir]

    This package can be installed by running:

    pkcon install-local com.ubuntu.address-book_*.click
