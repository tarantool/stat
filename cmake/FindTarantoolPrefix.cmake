# Define GNU standard installation directories
include(GNUInstallDirs)

macro(extract_prefix output input)
    string(REGEX MATCH "-DCMAKE_INSTALL_PREFIX=([^ ]+)" _t "${input}")
    string(REGEX REPLACE "-DCMAKE_INSTALL_PREFIX=([^ ]+)" "\\1"
        ${output} "${_t}")
endmacro()

if (NOT TARANTOOL_INSTALL_PREFIX)
    execute_process(COMMAND tarantool "--version"
        OUTPUT_VARIABLE _tarantool_version_output
        RESULT_VARIABLE retcode)
    if (NOT "${retcode}" STREQUAL "0")
        message(FATAL_ERROR "Cannot execute tarantool --version")
	endif()
    extract_prefix(TARANTOOL_INSTALL_PREFIX ${_tarantool_version_output})
endif()

if (NOT TARANTOOL_INSTALL_LUADIR)
    set(TARANTOOL_INSTALL_LUADIR "${CMAKE_INSTALL_DATADIR}/tarantool"
        CACHE PATH "Directory for storing Lua modules written in Lua")
endif()

if (NOT TARANTOOL_FIND_QUIETLY AND NOT FIND_TARANTOOL_DETAILS)
    set(FIND_TARANTOOL_DETAILS ON CACHE INTERNAL "Details about TARANTOOL")
    message(STATUS "Tarantool LUADIR is ${TARANTOOL_INSTALL_LUADIR}")
endif()

mark_as_advanced(TARANTOOL_INSTALL_LIBDIR TARANTOOL_INSTALL_LUADIR)
