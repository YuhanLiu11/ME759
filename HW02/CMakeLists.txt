cmake_minimum_required(VERSION 3.13)
project(HW02 C)

set(CMAKE_C_STANDARD 11)

include_directories(.)

add_executable(HW02
        convolution.h
        matmul.h
        scan.h)
