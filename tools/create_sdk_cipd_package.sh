#!/bin/bash

# This script requires depot_tools to be on path.

print_usage () {
  echo "Usage: create_sdk_cipd_package.sh <PACKAGE_TYPE> <PATH_TO_ASSETS> <PLATFORM_NAME> <VERSION_TAG>"
  echo "  where:"
  echo "    - PACKAGE_TYPE is one of build-tools, platform-tools, platforms, tools, or cmdline-tools;latest"
  echo "    - PATH_TO_ASSETS is the path to the unzipped asset folder"
  echo "    - PLATFORM_NAME is one of linux-amd64, mac-amd64, or windows-amd64"
  echo "    - VERSION_TAG is the version of the package, e.g. 28r6 or 28.0.3"
  echo ""
  echo "To download the packages, you would need to use sdkmanager, and"
  echo "use the env variable REPO_OS_OVERRIDE=(linux|windows|macosx) to override the host platform."
  echo "For example: REPO_OS_OVERRIDE=linux sdkmanager \"platform-tools\"."
  echo "Gotchas:".
  echo "* sdkmanager downloads the binaries to the Android SDK location (Check ANDROID_HOME or ANDROID_SDK_ROOT)."
  echo "* PATH_TO_ASSETS is the path to that ends with the package type. e.g. <android-sdk>/platforms"
  echo "* When you change REPO_OS_OVERRIDE, you would also need to delete the directory from the"
  echo "Android SDK location, so sdkmanager tries to download the binaries for the new platform."
  echo ""
  echo "For more see: https://developer.android.com/studio/command-line/sdkmanager"
}

if [[ $4 == "" ]]; then
  print_usage
  exit 1
fi

if [[ $1 != "build-tools" && $1 != "platform-tools" && $1 != "platforms" && $1 != "tools" ]]; then
  echo "Unrecognized paackage type $1."
  print_usage
  exit 1
fi

if [[ ! -d "$2" ]]; then
  echo "Directory $1 not found."
  print_usage
  exit 1
fi

if [[ $1 != "platforms" && $3 != "linux-amd64" && $3 != "mac-amd64" && $3 != "windows-amd64" ]]; then
  echo "Unsupported platform $3."
  echo "Valid options are linux-amd64, mac-amd64, windows-amd64."
  print_usage
  exit 1
fi

if [[ $1 == "platforms" ]]; then
  echo "Ignoring PLATFORM_NAME - this package is cross-platform."
  cipd create -in $2 -name flutter/android/sdk/$1 -install-mode copy -tag version:$4
else
  cipd create -in $2 -name flutter/android/sdk/$1/$3 -install-mode copy -tag version:$4
fi
