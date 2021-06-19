if ! which cmake >/dev/null ; then
  echo "Please, install CMAKE first"
  exit 1
fi

# Make with ios-toolchain
MAKE_SCRIPT="cmake ../libmdbx -G Xcode -DCMAKE_TOOLCHAIN_FILE=../../ios-cmake/ios.toolchain.cmake -DPLATFORM=OS64COMBINED -DENABLE_BITCODE=ON"

$(cd libmdbx && rm -rf build)
$(cd libmdbx && mkdir build)
$(cd libmdbx/build && ${MAKE_SCRIPT})
