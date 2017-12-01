local clock = require 'clock'

local util = {}

function util.time()
    return 0ULL + clock.time()
end

function util.gethostname()
  local ffi = require('ffi')
  ffi.cdef[[
      int gethostname(char *name, size_t len);
  ]]

  local size = 1024
  local name_buf = ffi.new("char[?]", size)
  ffi.C.gethostname(name_buf, size);

  return ffi.string(name_buf)
end

return util
