<<<<<<< HEAD

#
# Copyright (C) 2017 Tarantool AUTHORS: please see the [AUTHORS](AUTHORS.md) file.
#

install(FILES init.lua
    DESTINATION ${TARANTOOL_INSTALL_LUADIR}/stat)
install(FILES util.lua
  DESTINATION ${TARANTOOL_INSTALL_LUADIR}/stat)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/../tarantool.sh
    DESTINATION /usr/local/bin/)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/../tarantool_stat.sh
    DESTINATION /usr/local/bin/)
