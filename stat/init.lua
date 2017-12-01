---
---
---
---

local clock = require('clock')
local fiber = require('fiber')

local function stat()

    local stats = { }

    local st_time = clock.realtime()
    local st_cpu = clock.proc()

    do
        stats['cfg.listen'] = box.cfg.listen
    end

    do
        local i = box.info()
        stats['info.pid'] = i.pid
        stats['info.uuid'] = i.uuid
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
            stats["stat.op." .. k:lower()] = v.total
        end
    end

    do
        local i = box.stat.net()
        for k, v in pairs(i) do
            stats["stat.net." .. k:lower()] = v.total
        end
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

                if sp.engine == 'memtx' then
                    for _, i in pairs(sp.index) do
                        if type(_) == 'number' then
                            stats[sp_prefix .. '.index.' .. i.name .. '.bsize'] = i:bsize()
                            total = total + i:bsize()
                        end
                    end

                    local sp_bsize = sp:bsize()
                    stats[ sp_prefix .. '.len' ] = sp:len()
                    stats[ sp_prefix .. '.bsize' ] = sp_bsize
                    stats[ sp_prefix .. '.total_bsize' ] = sp_bsize + total
                else
                    stats[ sp_prefix .. '.count' ] = sp:count()
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

return {
    stat = stat
}
