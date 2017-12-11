#!/usr/bin/env tarantool

package.path = "../?/init.lua;./?/init.lua;" .. package.path

local tap = require 'tap'
local tnt = require 'tests.tnt'
local stat = require 'stat'


local function fixture_read_only()
    local backup
    return {
        f_start = function()
            backup = box.cfg.read_only
            box.cfg.read_only = true
        end,
        f_end = function()
            box.cfg.read_only = backup
        end
    }
end

local function fixture_replication_replica()
    local backup
    return {
        f_start = function()
            backup = box.info
            box.info = function()
                return {
                    replication =   { [1] = { lsn = 5 }, [2] = { lsn = 0 } },
                    vclock =        { [1] = 4 }
                }
            end
        end,
        f_end = function()
            box.info = backup
        end
    }
end

local function fixture_replication_master()
    local backup
    return {
        f_start = function()
            backup = box.info
            box.info = function()
                return {
                    id = 1, lsn = 32, vclock = { [1] = 32 },
                    replication =   {
                        [1] = { lsn = 32 },
                        [2] = {
                            downstream = { vclock = { [1] = 31 } }
                        }
                    }
                }
            end
        end,
        f_end = function()
            box.info = backup
        end
    }
end

local function fixture_replication()
    local backup
    return {
        f_start = function()
            backup = box.info
            box.info = function()
                return {
                    id = 1, lsn = 32, vclock = { [1] = 32 },
                    replication =   {
                        [1] = { uuid = '1', lsn = 32 },
                        [2] = { uuid = '2', upstream = { status = 'follow', lag = 15 } },
                        [3] = { uuid = '3', upstream = { status = 'follow', lag = 0 } },
                        [4] = { uuid = '4', upstream = { status = 'stopped', lag = 3 } }
                    }
                }
            end
        end,
        f_end = function()
            box.info = backup
        end
    }
end


local function test_replication_replica_info(test)
    test:plan(1)

    local read_only = fixture_read_only()
    read_only.f_start()
    local replication_replica = fixture_replication_replica()
    replication_replica.f_start()

    local s = stat.stat()

    test:is(s['replication.replica.1.lsn'], 1, 'replication.replica.1.lsn == 1')

    read_only.f_end()
    replication_replica.f_end()
end

local function test_replication_master_info(test)
    test:plan(1)

    local replication_master = fixture_replication_master()
    replication_master.f_start()

    local s = stat.stat()

    test:is(s['replication.master.2.lsn'], 1, 'replication.master.1.lsn == 1')

    replication_master.f_end()
end

local function test_replication_status(test)
    test:plan(5)

    local replication = fixture_replication()
    replication.f_start()

    local check
    check = stat.check_replica({ exclude = { 'follow' }})
    test:is(#check, 1, 'number of non-follow replica is one')
    test:is(check[1], '4', 'uuid of non-follow replica is 4')

    check = stat.check_replica({ include = { 'follow' }})
    test:is(#check, 2, 'number of follow replica is two')
    test:is(check[1], '2', 'uuid of follow replica is 2')
    test:is(check[2], '3', 'uuid of follow replica is 3')

    replication.f_end()
end

local function test_replication_lag(test)
    test:plan(3)

    local replication = fixture_replication()
    replication.f_start()

    local check
    check = stat.check_replica({ lag = 10, include = { 'follow' } })
    test:is(#check, 1, 'number of replica that have lag gt then 10 is one')
    test:is(check[1], '2', 'uuid of replica that have lag gt then 10 is is 2')

    check = stat.check_replica({ lag = 10, exclude = { 'follow' } })
    test:is(#check, 0, 'does not exist replica that have lag gt then 10')

    replication.f_end()
end

local function main()
    local test = tap.test()
    test:plan(4)
    tnt.cfg { listen = 3301 }

    test:test('test_replication_replica_info', test_replication_replica_info)
    test:test('test_replication_master_info', test_replication_master_info)
    test:test('test_replication_status', test_replication_status)
    test:test('test_replication_lag', test_replication_lag)

    tnt.finish()
    os.exit(test:check() == true and 0 or -1)
end

main()