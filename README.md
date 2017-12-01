# stat - status mudule for Tarantool 1.7+[Tarantool][]

## Getting Started

### Prerequisites

 * Tarantool 1.6.5+ with header files (tarantool && tarantool-dev)

### Installation

Clone repository and then build it using CMake:

``` bash
git clone https://github.com/dedok/tarantool-stat.git
cd tarantool-stat && cmake . -DCMAKE_BUILD_TYPE=RelWithDebugInfo
make
make install
```

## API Documentation

### `st = stat.stat()`

returns various metrics about Tarantool

*Returns*:

 - `a table` on success
 - `error(reason)` on error

Example

``` lua
  tarantool> require('json').encode(require('stat').stat())
```

```
{
  // Number of various operations since Tarantool started
  "stat.op.delete":0,
  "stat.op.error":0,
  "stat.op.insert":0,
  "stat.op.eval":0,
  "stat.op.auth":0,
  "stat.op.update":0,
  "stat.op.replace":0,
  "stat.op.call":0,
  "stat.op.upsert":0,
  "stat.op.select":1,

  // Slab information
  // https://tarantool.org/doc/1.7/book/box/box_slab.html?highlight=slab%20info#lua-function.box.slab.info
  "slab.items_used":4728,
  "slab.arena_used":1102456,
  "slab.quota_used":8388608,
  "slab.arena_size":2325176,
  "slab.quota_size":268435456,
  "slab.items_size":228128,

  // Information about Fibers

  // Number of fibers
  "fiber.count":3,

  // Total fiber memory alloated
  "fiber.memalloc":177040,

  // Total fiber memory used
  "fiber.memused":0,
  "fiber.csw":102,

  // Perf information
  "statperf.stats_t":5.6982040405273e-05,
  "statperf.fibers":8.0000000000011e-06,
  "statperf.fibers_t":7.8678131103516e-06,
  "statperf.spaces_t":0.00010204315185547,
  "statperf.spaces":0.000103,
  "statperf.stats":5.4999999999999e-05,

  // Current last sequence number
  "info.lsn":0,

  // Uptime of this instance
  "info.uptime":20,

  // Number of packets passed via network interface
  "stat.net.received":0,
  // Same, but sent via network interface
  "stat.net.sent":0 ,

  // is the current memory size used by Lua
  "runtime.used":29360128,

  // is the heap size of the Lua garbage collector;
  "runtime.lua":1247700,

  // Pid
  "info.pid":16930
}
```

# See Also

 * [Tarantool][]

[Tarantool]: http://github.com/tarantool/tarantool
