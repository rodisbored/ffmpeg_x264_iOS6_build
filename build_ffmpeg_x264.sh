#Original Script taken from Matt Galloway
#Modified by Roderick Buenviaje
#Takes the ffmpeg code and builds armv7 version for iOS
#Building for armv6 has been disabled in SDK

#git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg

cd ./ffmpeg

export PLATFORM="iPhoneOS"
export MIN_VERSION="6.0"
export MAX_VERSION="6.1"
#change the below line to point to the where libx264 is
export X264ROOT=../x264/armv7
export X264LIB=$X264ROOT/lib
export X264INCLUDE=$X264ROOT/include
export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/${PLATFORM}.platform/Developer
export SDKROOT=$DEVROOT/SDKs/${PLATFORM}${MAX_VERSION}.sdk
export CC=$DEVROOT/usr/bin/llvm-gcc
export LD=$DEVROOT/usr/bin/ld
export CPP=$DEVROOT/usr/bin/cpp
export CXX=$DEVROOT/usr/bin/llvm-g++
export AR=$DEVROOT/usr/bin/ar
export LIBTOOL=$DEVROOT/usr/bin/libtool
export NM=$DEVROOT/usr/bin/nm
export CXXCPP=$DEVROOT/usr/bin/cpp
export RANLIB=$DEVROOT/usr/bin/ranlib

COMMONFLAGS="-pipe -gdwarf-2 -no-cpp-precomp -isysroot ${SDKROOT} -marm -fPIC"
export LDFLAGS="${COMMONFLAGS} -fPIC"
export CFLAGS="${COMMONFLAGS} -fvisibility=hidden"
export CXXFLAGS="${COMMONFLAGS} -fvisibility=hidden -fvisibility-inlines-hidden"

FFMPEG_LIBS="libavcodec libavdevice libavformat libavutil libswscale"

echo "Building armv7..."

make clean
./configure \
    --cpu=cortex-a8 \
    --extra-cflags='-I$X264INCLUDE -arch armv7 -miphoneos-version-min=${MIN_VERSION} -mthumb' \
    --extra-ldflags='-L$X264LIB -arch armv7 -miphoneos-version-min=${MIN_VERSION}' \
    --enable-cross-compile \
    --arch=arm \
    --target-os=darwin \
    --cc=${CC} \
    --sysroot=${SDKROOT} \
    --prefix=installed \
    --disable-network \
    --disable-decoders \
    --disable-muxers \
    --disable-demuxers \
    --disable-devices \
    --disable-parsers \
    --disable-encoders \
    --disable-protocols \
    --disable-armv5te \
    --disable-armv6 \
    --disable-armv6t2 \
    --disable-filters \
    --disable-filter=aformat \
    --disable-filter=anull \
    --disable-filter=atrim \
    --disable-filter=format \
    --disable-filter=null \
    --disable-filter=setpts \
    --disable-filter=trim \
    --disable-bsfs \
    --enable-libx264 \
    --enable-encoder=libx264 \
    --enable-encoder=libx264rgb \
    --enable-decoder=h264 \
    --enable-decoder=svq3 \
    --enable-gpl \
    --enable-pic \
    --disable-doc
perl -pi -e 's/HAVE_INLINE_ASM 1/HAVE_INLINE_ASM 0/' config.h
make -j3

mkdir -p build.armv7
for i in ${FFMPEG_LIBS}; do cp ./$i/$i.a ./build.armv7/; done

make install
