cmake_minimum_required(VERSION 2.8)

project(stat)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

find_package(Tarantool REQUIRED)
include_directories(${TARANTOOL_INCLUDE_DIRS})

install(FILES stat.lua DESTINATION ${TARANTOOL_INSTALL_LUADIR}/)
install(FILES tarantool.sh DESTINATION /usr/local/bin)
install(FILES tarantool_stat.sh DESTINATION /usr/local/bin)
