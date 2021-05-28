if ! which cmake >/dev/null ; then
  echo "Please, install CMAKE first"
  exit 1
fi


# Make with ios-toolchain
MAKE_SCRIPT="cmake .. -G Xcode -DCMAKE_TOOLCHAIN_FILE=../../ios-cmake/ios.toolchain.cmake -DPLATFORM=OS64COMBINED -DENABLE_BITCODE=ON -DCMAKE_C_FLAGS_DEBUG=-Wno-error=shorten-64-to-32 -DCMAKE_C_FLAGS_RELEASE=-Wno-error=shorten-64-to-32 -DMDBX_BUILD_SHARED_LIBRARY=0 -DMDBX_ENABLE_TESTS=0"

$(cd libmdbx && mkdir build)
$(cd libmdbx/build && ${MAKE_SCRIPT})

# Build
cd libmdbx-ios

ARCHIVES=archives
PROJECT_NAME=libmdbx-ios
FRAMEWORK_NAME=libmdbx_ios.framework
XCFRAMEWORK_NAME=libmdbx_ios.xcframework
XCFRAMEWORKZIP_NAME=libmdbx_ios.xcframework.zip
SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
BUILD_PATH=`dirname $SCRIPT`

BUILD_MATRIX_WIDTH=5
buildmatrix=()
#               PLATFORM            PLATFORM_EXTRAS            BCMAPS_INCLUDED    EXTRA_PARAMETERS                              ARCHIVE_NAME
#iOS Simulator
buildmatrix+=("iOS Simulator"       ""                         false              "ONLY_ACTIVE_ARCH=NO -sdk iphonesimulator"    "simulator")
#iOS
buildmatrix+=("iOS"                 ""                         true               "-sdk iphoneos"                               "ios")
#macOS
buildmatrix+=("macOS"               ",variant=Mac Catalyst"    false              ""                                            "catalyst")
buildmatrix+=("macOS"               ""                         false              " -sdk macosx"                                "mac")

count=$((${#buildmatrix[@]}/$BUILD_MATRIX_WIDTH))

i="0"

FRAMEWORKS=""

rm -r ${ARCHIVES}

while [ $i -lt ${count} ]
  do
    PLATFORM=${buildmatrix[$(($i*$BUILD_MATRIX_WIDTH))]}
    PLATFORM_EXTRAS=${buildmatrix[$(($i*$BUILD_MATRIX_WIDTH+1))]}
    BCMAPS_INCLUDED=${buildmatrix[$(($i*$BUILD_MATRIX_WIDTH+2))]}
    EXTRA_PARAMETERS=${buildmatrix[$(($i*$BUILD_MATRIX_WIDTH+3))]}
    ARCHIVE_NAME=${buildmatrix[$(($i*$BUILD_MATRIX_WIDTH+4))]}
    
    ARCHIVE_PATH_WO_EXTENSION="${ARCHIVES}/${ARCHIVE_NAME}"
    ARCHIVE_PATH=${ARCHIVE_PATH_WO_EXTENSION}.xcarchive

    # To make an XCFramework, we first build the framework for every type seperately
    echo "XCFramework: Archiving ${PLATFORM}..."

    xcodebuild archive ${EXTRA_PARAMETERS} -project ${PROJECT_NAME}.xcodeproj -scheme ${PROJECT_NAME} -destination "generic/platform=${PLATFORM}${PLATFORM_EXTRAS}" -archivePath ${ARCHIVE_PATH_WO_EXTENSION} SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES -configuration Release

    echo "XCFramework: Generating ${PLATFORM} BCSymbolMap paths..."

    FRAMEWORK_PATH=${ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}
    DSYMS_PATH=${BUILD_PATH}/${ARCHIVE_PATH}/dSYMs/${FRAMEWORK_NAME}.dSYM
    echo ${BUILD_PATH}

    if $BCMAPS_INCLUDED ; then
      BCSYMBOLMAP_PATHS=(${ARCHIVE_PATH}/BCSymbolMaps/*)
      BCSYMBOLMAP_COMMANDS=""
      for path in "${BCSYMBOLMAP_PATHS[@]}"; do
        BCSYMBOLMAP_COMMANDS="$BCSYMBOLMAP_COMMANDS -debug-symbols $BUILD_PATH/$path "
      done
      FRAMEWORKS+="-framework ${FRAMEWORK_PATH} -debug-symbols ${DSYMS_PATH} ${BCSYMBOLMAP_COMMANDS} "
    else
      FRAMEWORKS+="-framework ${FRAMEWORK_PATH} -debug-symbols ${DSYMS_PATH} "
    fi

    i=$[$i+1]
done

rm -r ${XCFRAMEWORK_NAME}
xcodebuild -create-xcframework ${FRAMEWORKS} -output ${XCFRAMEWORK_NAME}

XCFRAMEWORKZIP_PATH=../${XCFRAMEWORKZIP_NAME}
rm -r ${XCFRAMEWORKZIP_PATH}
zip -vr ${XCFRAMEWORKZIP_PATH} ${XCFRAMEWORK_NAME} -x "*.DS_Store"
echo "XCFFramework checksum: " $(swift package compute-checksum ${XCFRAMEWORKZIP_PATH})

# Remove xcframework
rm -r ${XCFRAMEWORK_NAME}
# Remove archives
rm -r ${ARCHIVES}
# libmdbx
cd ../libmdbx
rm -rf build
rm mdbx.h++-e

open ${BUILD_PATH}
