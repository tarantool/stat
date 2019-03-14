---
--- Copyright (C) 2017 Tarantool AUTHORS: please see the [AUTHORS](AUTHORS.md) file.
--
--- Redistribution and use in source and binary forms, with or
--- without modification, are permitted provided that the following
--- conditions are met:
---
--- 1. Redistributions of source code must retain the above
---    copyright notice, this list of conditions and the
---    following disclaimer.
---
--- 2. Redistributions in binary form must reproduce the above
---    copyright notice, this list of conditions and the following
---    disclaimer in the documentation and/or other materials
---    provided with the distribution.
---
--- THIS SOFTWARE IS PROVIDED BY <COPYRIGHT HOLDER> "AS IS" AND
--- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
--- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
--- A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
--- <COPYRIGHT HOLDER> OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
--- INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
--- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
--- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
--- BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
--- LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
--- THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
--- SUCH DAMAGE.
---
---

local clock = require('clock')
local fiber = require('fiber')
local util = require('stat/util')


local function stat(args)
    args = args or {}

    local include_vinyl_count = args.include_vinyl_count
    if include_vinyl_count == nil then
        include_vinyl_count = true
    end
    local only_numbers = args.only_numbers or false

    local stats = {}

    local st_time = clock.realtime()
    local st_cpu = clock.proc()

    do
        if not only_numbers then
            stats['cfg.listen'] = box.cfg.listen
            stats['cfg.hostname'] = util.gethostname()
            stats['cfg.read_only'] = box.cfg.read_only
        end
        stats['cfg.current_time'] = util.time()
    end

    do
        local i = box.info()

        if box.cfg.read_only then
            for k, v in ipairs(i.vclock) do
                local lsn = i.replication[k].lsn
                stats['replication.replica.' .. k .. '.lsn'] = lsn - v
            end
        else
            for k, v in ipairs(i.replication) do
                if v.downstream ~= nil and v.downstream.vclock ~= nil then
                    local lsn = v.downstream.vclock[i.id]
                    if lsn ~= nil and i.lsn ~= nil then
                        stats['replication.master.' .. k .. '.lsn'] = i.lsn - lsn
                    end
                end
            end
        end
    end

    do
        local i = box.info()
        if not only_numbers then
            stats['info.uuid'] = i.uuid
        end
        stats['info.pid'] = i.pid
        stats['info.lsn'] = i.lsn
        stats['info.uptime'] = i.uptime

        for k, v in ipairs(i.vclock) do
            stats['info.vclock.' .. k] = v
        end

        for k, v in ipairs(i.replication) do
            if v.upstream ~= nil then
                stats['info.replication.' .. k .. '.lag'] = v.upstream.lag
            end
        end
    end

    do
        local i = box.slab.info()
        for k, v in pairs(i) do
            if not k:match('_ratio$') then
                stats['slab.' .. k] = v
            else
                stats['slab.' .. k] = tonumber(v:match('^([0-9%.]+)%%?$'))
            end
        end
    end

    do
        local i = box.runtime.info()
        for k, v in pairs(i) do
            if k ~= 'maxalloc' then
                stats['runtime.' .. k] = v
            end
        end
    end

    do
        local i = box.stat()
        for k, v in pairs(i) do
            stats['stat.op.' .. k:lower() .. '.total'] = v.total
            stats['stat.op.' .. k:lower() .. '.rps'] = v.rps
        end
    end

    do
        if box.info.memory ~= nil then
            local i = box.info.memory()
            for k, v in pairs(i) do
                stats['info.memory.' .. k] = v
            end
        end
    end

    do
        local box_stat_net = box.stat.net()
        stats['stat.net.sent.total'] = box_stat_net.SENT.total
        stats['stat.net.sent.rps'] = box_stat_net.SENT.rps
        stats['stat.net.received.total'] = box_stat_net.RECEIVED.total
        stats['stat.net.received.rps'] = box_stat_net.RECEIVED.rps
    end

    local ed_time = clock.realtime()
    local ed_cpu = clock.proc()

    stats['statperf.stats'] = ed_cpu - st_cpu
    stats['statperf.stats_t'] = ed_time - st_time

    st_time = ed_time
    st_cpu = ed_cpu

    do
        for _, s in box.space._space:pairs {} do
            local total = 0
            local space_name = s[3]
            local flags = s[6]

            if not flags.temporary and not space_name:match('^_') then
                local sp = box.space[space_name]
                local sp_prefix = 'space.' .. sp.name

                for _, i in pairs(sp.index) do
                    if type(_) == 'number' then
                        stats[sp_prefix .. '.index.' .. i.name .. '.bsize'] = i:bsize()
                        total = total + i:bsize()
                    end
                end

                if sp.engine == 'memtx' then
                    local sp_bsize = sp:bsize()
                    stats[ sp_prefix .. '.len' ] = sp:len()
                    stats[ sp_prefix .. '.bsize' ] = sp_bsize
                    stats[ sp_prefix .. '.index_bsize' ] = total
                    stats[ sp_prefix .. '.total_bsize' ] = sp_bsize + total
                else
                    if include_vinyl_count then
                        stats[ sp_prefix .. '.count' ] = sp:count()
                    end
                    stats[ sp_prefix .. '.index_bsize' ] = total
                end
            end
        end
    end

    ed_time = clock.realtime()
    ed_cpu = clock.proc()

    stats['statperf.spaces'] = ed_cpu - st_cpu
    stats['statperf.spaces_t'] = ed_time - st_time
    st_time = ed_time
    st_cpu = ed_cpu

    do
        local i = fiber.info()
        local fibers = 0
        local csws = 0
        local falloc = 0
        local fused = 0

        for id, f in pairs(i) do
            fibers = fibers + 1
            csws = csws + f.csw
            falloc = falloc + f.memory.total
            fused = fused + f.memory.used
        end

        stats['fiber.count'] = fibers
        stats['fiber.csw'] = csws
        stats['fiber.memalloc'] = falloc
        stats['fiber.memused'] = fused
    end

    ed_time = clock.realtime()
    ed_cpu = clock.proc()
    stats['statperf.fibers'] = ed_cpu - st_cpu
    stats['statperf.fibers_t'] = ed_time - st_time

    return stats
end

local function _check_replica_status(r, exclude, include)
    local res = {}

    for k, v in ipairs(r) do
        if v.upstream ~= nil then
            if exclude[v.upstream.status] == nil and next(exclude) ~= nil or
                include[v.upstream.status] ~= nil then
                table.insert(res, v)
            end
        end
    end

    return res
end

local function _check_replica_lag(r, max_allowed_lag)
    local res = {}

    for k, v in ipairs(r) do
        if v.upstream ~= nil then
            if v.upstream.lag > max_allowed_lag then
                table.insert(res, v)
            end
        end
    end

    return res
end

local function check_replica(args)
    args = args or {}
    local exclude = {}
    local include = {}

    if args.exclude then
        for _, status in ipairs(args.exclude) do
            exclude[status] = true
        end
    elseif args.include then
        for _, status in ipairs(args.include) do
            include[status] = true
        end
    end

    local r = _check_replica_status(box.info().replication, exclude, include)
    if args.lag then
        r = _check_replica_lag(r, args.lag)
    end

    local res = {}
    for _, v in ipairs(r) do
        table.insert(res, v.uuid)
    end

    return res
end

return {
    stat = stat,
    check_replica = check_replica
}
