cmake_minimum_required(VERSION 3.4.1)
project(ReactNativeArculusCsdk)

set (CMAKE_VERBOSE_MAKEFILE ON)
set (CMAKE_CXX_STANDARD 14)

add_library(aptos-labs-react-native-arculus-csdk            SHARED
            ../cpp/aptos-labs-react-native-arculus-csdk.cpp
            cpp-adapter.cpp
)

# Specifies a path to native header files.
include_directories(
            ../cpp
)
