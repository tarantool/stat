package = 'stat'
version = 'scm-1'
source  = {
    url    = 'git@github.com:tarantool/stat.git',
    branch = 'master',
}
description = {
    summary  = 'Statistic module for Tarantool',
    homepage = 'https://github.com/tarantool/stat',
    license  = 'BSD',
}
dependencies = {
    'lua >= 5.1';
}
build = {
    type = 'cmake';
    variables = {
        TARANTOOL_INSTALL_LUADIR="$(LUADIR)";
    };
}

-- vim: syntax=lua