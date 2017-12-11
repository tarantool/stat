#!/usr/bin/env tarantool

package.path = "../?/init.lua;./?/init.lua;" .. package.path

local tap = require 'tap'
local tnt = require 'tests.tnt'
local stat = require 'stat'


local function test_cfg(test)
    test:plan(4)

    local s = stat.stat()

    test:isstring(s['cfg.listen'], 'check cfg.listen')
    test:ok(tonumber(s['cfg.current_time']) ~= nil, 'check cfg.current_time')
    test:isstring(s['cfg.hostname'], 'check cfg.hostname')
    test:isboolean(s['cfg.read_only'], 'check cfg.read_only')
end

local function test_info(test)
    test:plan(4)

    local s = stat.stat()

    test:isnumber(s['info.pid'], 'check info.pid')
    test:isstring(s['info.uuid'], 'check info.uuid')
    test:isnumber(s['info.lsn'], 'check info.lsn')
    test:isnumber(s['info.uptime'], 'check info.uptime')
end

local function test_slab(test)
    test:plan(9)

    local s = stat.stat()

    test:isnumber(s['slab.items_size'], 'check slab.items_size')
    test:isnumber(s['slab.items_used'], 'check slab.items_used')
    test:isnumber(s['slab.items_used_ratio'], 'check slab.items_used_ratio')

    test:isnumber(s['slab.quota_size'], 'check slab.quota_size')
    test:isnumber(s['slab.quota_used'], 'check slab.quota_used')
    test:isnumber(s['slab.quota_used_ratio'], 'check slab.quota_used_ratio')

    test:isnumber(s['slab.arena_size'], 'check slab.arena_size')
    test:isnumber(s['slab.arena_used'], 'check slab.arena_used')
    test:isnumber(s['slab.arena_used_ratio'], 'check slab.arena_used_ratio')
end

local function test_runtime(test)
    test:plan(3)

    local s = stat.stat()

    test:isnumber(s['runtime.lua'], 'check runtime.lua')
    test:isnumber(s['runtime.used'], 'check runtime.used')
    test:isnil(s['runtime.maxalloc'], 'check that runtime.maxalloc is nil')
end

local function test_stat(test)
    test:plan(20)

    local ops = {
        'delete', 'select', 'insert', 'eval', 'call',
        'replace', 'upsert', 'auth', 'error', 'update'
    }

    local s = stat.stat()

    local function _check(op)
        test:isnumber(s['stat.op.' .. op .. '.total'], 'check stat.op.' .. op .. 'total')
        test:isnumber(s['stat.op.' .. op .. '.rps'], 'check stat.op.' .. op .. 'rps')
    end

    for _, op in ipairs(ops) do
        _check(op)
    end
end

local function test_stat_net(test)
    test:plan(4)

    local s = stat.stat()

    test:isnumber(s['stat.net.sent.total'], 'check stat.net.sent.total')
    test:isnumber(s['stat.net.sent.rps'], 'check stat.net.sent.rps')

    test:isnumber(s['stat.net.received.total'], 'check stat.net.received.total')
    test:isnumber(s['stat.net.received.rps'], 'check stat.net.received.rps')
end

local function test_space(test)
    test:plan(5)

    local sp = box.schema.space.create('test', {})
    sp:create_index('primary', {unique = true, parts = {1, 'unsigned',}})

    local s = stat.stat()

    test:isnumber(s['space.test.len'], 'check space.test.len')
    test:isnumber(tonumber(s['space.test.bsize']), 'check space.test.bsize')
    test:isnumber(tonumber(s['space.test.index_bsize']), 'check space.test.index_bsize')
    test:isnumber(tonumber(s['space.test.total_bsize']), 'check space.test.total_bsize')

    test:isnumber(tonumber(s['space.test.index.primary.bsize']), 'check space.test.index.primary.bsize')
end

local function test_fiber(test)
    test:plan(4)

    local s = stat.stat()

    test:isnumber(s['fiber.count'], 'check fiber.count')
    test:isnumber(s['fiber.csw'], 'check fiber.csw')
    test:isnumber(s['fiber.memalloc'], 'check fiber.memalloc')
    test:isnumber(s['fiber.memused'], 'check fiber.memused')
end


local function main()
    local test = tap.test()
    test:plan(8)
    tnt.cfg { listen = 3301 }

    test:test('test_cfg', test_cfg)
    test:test('test_info', test_info)
    test:test('test_slab', test_slab)
    test:test('test_runtime', test_runtime)
    test:test('test_stat', test_stat)
    test:test('test_stat_net', test_stat_net)
    test:test('test_space', test_space)
    test:test('test_fiber', test_fiber)

    tnt.finish()
    os.exit(test:check() == true and 0 or -1)
end

main()