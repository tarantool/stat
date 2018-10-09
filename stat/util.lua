
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

local clock = require 'clock'
local ffi = require('ffi')

local util = {}

function util.time()
    return 0ULL + clock.time()
end

if not pcall(function() return ffi.C.gethostname end) then
    -- This should not be called too many times.
    -- Thousands of ffi.cdef calls may cause "table overflow" error.
    -- So we wrap it with a pcall check to allow unloading/loading
    -- this module many times but declare gethostname only once.
    ffi.cdef[[
        int gethostname(char *name, size_t len);
    ]]
end

function util.gethostname()
  local size = 1024
  local name_buf = ffi.new("char[?]", size)
  ffi.C.gethostname(name_buf, size);
  return ffi.string(name_buf)
end

function util.get_replica_host(peer)
    local _, host = string.match(peer, '(.+)@(.+)')
    return host
end

function util.get_my_replica_host()
    local all_hosts = {}
    for _, v in ipairs(box.cfg.replication) do
        local host = util.get_replica_host(v)
        all_hosts[host] = true
    end

    for _, v in ipairs(box.info.replication) do
        if v.upstream ~= nil then
            local host = util.get_replica_host(v.upstream.peer)
            all_hosts[host] = nil
        end
    end

    return next(all_hosts)
end

return util
