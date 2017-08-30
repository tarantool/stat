cmake_minimum_required(VERSION 2.8)

project(stat)

install(FILES stat.lua DESTINATION /usr/local/share/tarantool)
install(FILES tarantool.sh DESTINATION /usr/local/bin)
install(FILES tarantool_stat.sh DESTINATION /usr/local/bin)
