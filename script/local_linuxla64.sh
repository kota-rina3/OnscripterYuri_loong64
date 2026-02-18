# bash -c "BUILD_TYPE=Debug OBTAIN_DEPENDS=yes ./local_linux64.sh"
PLATFORM=linux64
BUILD_PATH=./../build_${PLATFORM}
CMAKELISTS_PATH=$(pwd)/..
PORTBUILD_PATH=$CMAKELISTS_PATH/thirdparty/build/arch_$PLATFORM
CORE_NUM=$(cat /proc/cpuinfo | grep -c ^processor)
TARGETS=$@

# config env
CC=gcc
CXX=g++
if [ -z "$BUILD_TYPE" ]; then BUILD_TYPE=MinSizeRel; fi
if [ -z "$TARGETS" ]; then TARGETS=all; fi

# ports from debian
if [ -n "$OBTAIN_DEPENDS" ]; then
    sudo apt update && sudo apt install -y libsdl2-dev libsdl2-ttf-dev libsdl2-image-dev libsdl2-mixer-dev install libbz2-dev libjpeg-dev libpng-dev liblua5.4-dev libgl1-mesa-dev
fi

sudo ln -s /usr/lib/loongarch64-linux-gnu/liblua5.4.so /usr/lib/loongarch64-linux-gnu/liblua.so && sudo ldconfig

# config and build project
echo "BUILD_TYPE=$BUILD_TYPE"

cmake -B $BUILD_PATH -S $CMAKELISTS_PATH \
    -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX \
    -DCMAKE_C_FLAGS=-"-march=loongarch64 -mabi=lp64d -L/usr/lib/loongarch64-linux-gnu" -DCMAKE_CXX_FLAGS="-march=loongarch64 -mabi=lp64d -L/usr/lib/loongarch64-linux-gnu"

make -C $BUILD_PATH $TARGETS -j$CORE_NUM