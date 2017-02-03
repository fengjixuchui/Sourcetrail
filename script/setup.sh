#!/bin/bash

set -e

ABORT="\033[31mAbort:\033[00m"
SUCCESS="\033[32mSuccess:\033[00m"
INFO="\033[33mInfo:\033[00m"

# Determine current platform
PLATFORM='unknown'
if [ "$(uname)" == "Darwin" ]; then
	PLATFORM='MacOS'
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
	PLATFORM='Linux'
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
	PLATFORM='Windows'
fi

if [ $PLATFORM == "Windows" ]; then
	ORIGINAL_PATH_TO_SCRIPT="${0}"
	CLEANED_PATH_TO_SCRIPT="${ORIGINAL_PATH_TO_SCRIPT//\\//}"
	ROOT_DIR=`dirname "$CLEANED_PATH_TO_SCRIPT"`
else
	ROOT_DIR="$( cd "$( dirname "$0" )" && pwd )"
fi

ROOT_DIR=$ROOT_DIR/..

# Enter masterproject directory
cd $ROOT_DIR

# git settings
echo -e $INFO "install git settings"

git config commit.template setup/git/git_commit_template.txt
git config color.ui true
if [ -d ".git/hooks" ]
then
cp setup/git/git_pre_commit_hook.sh .git/hooks/pre-commit
cp setup/git/git_pre_push_hook.sh .git/hooks/pre-push
fi

# Copy necessary jars for java indexer
echo -e $INFO "copy jars for java indexer"

mkdir -p java_indexer/lib

if [ $PLATFORM == "Windows" ]; then
	cp -u -r setup/jars/windows/*.jar java_indexer/lib
elif [ $PLATFORM == "Linux" ]; then
	cp -u -r setup/jars/linux/*.jar java_indexer/lib
	# what about 32/64 bit?
elif [ $PLATFORM == "MacOS" ]; then
	cp -r setup/jars/MacOSX/*.jar java_indexer/lib
fi

# Create Debug and Release folders
echo -e $INFO "create build folders"
if [ $PLATFORM == "Windows" ]; then
	mkdir -p build/win32/Debug/app
	mkdir -p build/win32/Debug/test
	mkdir -p build/win32/Release/app
	mkdir -p build/win32/Release/test
	mkdir -p build/win64/Debug/app
	mkdir -p build/win64/Debug/test
	mkdir -p build/win64/Release/app
	mkdir -p build/win64/Release/test
else
	mkdir -p build/Debug/app
	mkdir -p build/Debug/test
	mkdir -p build/Release/app
	mkdir -p build/Release/test
fi

# Copy necessary dynamic libraries to bin folder
if [ $PLATFORM == "Windows" ]; then
	echo -e $INFO "copy dynamic libraries"
	cp -u -r setup/dynamic_libraries/win32/app/Debug/* build/win32/Debug/app
	cp -u -r setup/dynamic_libraries/win32/app/Release/* build/win32/Release/app
	
	cp -u -r setup/dynamic_libraries/win64/app/Debug/* build/win64/Debug/app
	cp -u -r setup/dynamic_libraries/win64/app/Release/* build/win64/Release/app
	
	cp -u -r setup/dynamic_libraries/win32/app/Debug/Qt5* build/win32/Debug/test
	cp -u -r setup/dynamic_libraries/win32/app/Debug/platforms* build/win32/Debug/test/platforms
	cp -u -r setup/dynamic_libraries/win32/app/Release/Qt5* build/win32/Release/test
	cp -u -r setup/dynamic_libraries/win32/app/Release/platforms* build/win32/Release/test/platforms
	
	cp -u -r setup/dynamic_libraries/win64/app/Debug/Qt5* build/win64/Debug/test
	cp -u -r setup/dynamic_libraries/win64/app/Debug/platforms* build/win64/Debug/test/platforms
	cp -u -r setup/dynamic_libraries/win64/app/Release/Qt5* build/win64/Release/test
	cp -u -r setup/dynamic_libraries/win64/app/Release/platforms* build/win64/Release/test/platforms

	echo -e $INFO "copy test_main file"
	cp -u setup/cxx_test/windows/test_main.cpp build/win32
	cp -u setup/cxx_test/windows/test_main.cpp build/win64

	echo -e $INFO "creating program icon"
	sh script/create_windows_icon.sh
fi

echo -e $INFO "create symbolic links for data"
if [ $PLATFORM == "Windows" ]; then
	BACKSLASHED_ROOT_DIR="${ROOT_DIR//\//\\}"
	cmd //c 'mklink /d /j '$BACKSLASHED_ROOT_DIR'\build\win32\Debug\app\data '$BACKSLASHED_ROOT_DIR'\bin\app\data' &
	cmd //c 'mklink /d /j '$BACKSLASHED_ROOT_DIR'\build\win32\Debug\app\user '$BACKSLASHED_ROOT_DIR'\bin\app\user' &
	cmd //c 'mklink /d /j '$BACKSLASHED_ROOT_DIR'\build\win32\Release\app\data '$BACKSLASHED_ROOT_DIR'\bin\app\data' &
	cmd //c 'mklink /d /j '$BACKSLASHED_ROOT_DIR'\build\win32\Release\app\user '$BACKSLASHED_ROOT_DIR'\bin\app\user' &
	
	cmd //c 'mklink /d /j '$BACKSLASHED_ROOT_DIR'\build\win64\Debug\app\data '$BACKSLASHED_ROOT_DIR'\bin\app\data' &
	cmd //c 'mklink /d /j '$BACKSLASHED_ROOT_DIR'\build\win64\Debug\app\user '$BACKSLASHED_ROOT_DIR'\bin\app\user' &
	cmd //c 'mklink /d /j '$BACKSLASHED_ROOT_DIR'\build\win64\Release\app\data '$BACKSLASHED_ROOT_DIR'\bin\app\data' &
	cmd //c 'mklink /d /j '$BACKSLASHED_ROOT_DIR'\build\win64\Release\app\user '$BACKSLASHED_ROOT_DIR'\bin\app\user' &
elif [ $PLATFORM == "Linux" ]; then
	cd $ROOT_DIR/build/Release/app
	ln -s -f $ROOT_DIR/bin/app/data
	cd $ROOT_DIR/build/Debug/app
	ln -s -f $ROOT_DIR/bin/app/data
	cd $ROOT_DIR
fi

# Setup both Debug and Release configuration
if [ $PLATFORM == "Linux" ] || [ $PLATFORM == "MacOS" ]; then
	mkdir -p build/Debug
	mkdir -p build/Release

	echo -e $INFO "run cmake with Debug configuration"
	cd build/Debug && cmake -G Ninja -DCMAKE_BUILD_TYPE="Debug" ../..

	echo -e $INFO "run cmake with Release configuration"
	cd ../Release && cmake -G Ninja -DCMAKE_BUILD_TYPE="Release" ../..
else
	echo -e $INFO "run cmake with 32 bit configuration"
	
	cd build/win32
	cmake -G "Visual Studio 14 2015" ../..
	
	cd ../win64
	cmake -G "Visual Studio 14 2015 Win64" ../..
fi

echo -e $SUCCESS "setup complete"
