# stat - the status module for Tarantool 1.7+ [Tarantool][]

Forked from https://github.com/dedok/tarantool-stat

## Installation
1. Add [tarantool repository](http://tarantool.org/download.html) for
   yum or apt
2. Install
```bash
$ sudo [yum|apt-get] install tarantool tarantool-stat
```

## Getting Started

### Prerequisites

 * Tarantool 1.7+ with header files (tarantool && tarantool-dev)

## API Documentation

### `st = stat.stat()`

returns various metrics about Tarantool

*Args*:
 - `include_vinyl_count` - include space:count if engine is vinyl, default value is false
 - `only_numbers` - include only numeric metrics, default value is false

*Returns*:

 - `a table` on success
 - `error(reason)` on error

Example

``` lua
  tarantool> require('json').encode(require('stat').stat({ only_numbers = true }))
```

```
{
  //
  // Number of config options
  "cfg.listen":"3301",
  "cfg.current_time":1512430376,
  "cfg.hostname":"some_hostname",
  "cfg.read_only":false,
  
  //
  // Lag if instance is readonly 
  "replication.replica.<instance_id>.lsn":0,
  
  // Lag if instance is not readonly 
  "replication.master.<instance_id>.lsn":0,
  
  "info.pid":16930,
  "info.uuid":"b2441213-5663-4be0-8c0e-1c887f0d7c7b",
  
  // Current last sequence number
  "info.lsn":0,
  
  // Uptime of this instance
  "info.uptime":20,
  
  // Corresponds to replication.downstream.vclock - the instance’s vector clock 
  "info.vclock.<instance_id>":12,
  
  // The time difference between the local time at the instance, recorded when the event was received, 
  // and the local time at another master recorded when the event was written to the write ahead log on that master
  "info.replication.<instance_id>.lag":0.00001,
  
  //
  // Slab information
  // https://tarantool.org/doc/1.7/book/box/box_slab.html?highlight=slab%20info#lua-function.box.slab.info
  "slab.arena_size":5415928,
  "slab.arena_used":3062008,
  "slab.arena_used_ratio":56.5,
  "slab.items_size":1221832,
  "slab.items_used":735480,
  "slab.items_used_ratio":60.19,
  "slab.quota_size":104857600,
  "slab.quota_used":33554432,
  "slab.quota_used_ratio":32,
  
  //
  // is the current memory size used by Lua
  "runtime.used":29360128,
  // is the heap size of the Lua garbage collector;
  "runtime.lua":1247700,
  
  //
  // Number of various operations since Tarantool started
  "stat.op.delete.total":0,
  "stat.op.delete.rps":0,
  "stat.op.error.total":0,
  "stat.op.error.rps":0,
  "stat.op.insert.total":0,
  "stat.op.insert.rps":0,
  "stat.op.eval.total":0,
  "stat.op.eval.rps":0,
  "stat.op.auth.total":0,
  "stat.op.auth.rps":0,
  "stat.op.update.total":0,
  "stat.op.update.rps":0,
  "stat.op.replace.total":0,
  "stat.op.replace.rps":0,
  "stat.op.call.total":0,
  "stat.op.call.rps":0,
  "stat.op.upsert.total":0,
  "stat.op.upsert.rps":0,
  "stat.op.select.total":1,
  "stat.op.select.rps":0,
  
  //
  // Information about spaces
  // Number of rows in space if memtx
  "space.<space_name>.len":2,
  // Number of rows in space if vinyl
  "space.<space_name>.count":2,
  // Size of space in bytes
  "space.<space_name>.bsize":20,
  // Size of space indexs in bytes
  "space.<space_name>.index_bsize":10,
  // Total size of space
  "space.<space_name>.total_bsize":10,
  
  //
  // Information about Fibers
  // Number of fibers
  "fiber.count":3,
  // Total fiber memory alloated
  "fiber.memalloc":177040,
  // Total fiber memory used
  "fiber.memused":0,
  "fiber.csw":102,
  
  //
  // Perf information
  "statperf.stats_t":5.6982040405273e-05,
  "statperf.fibers":8.0000000000011e-06,
  "statperf.fibers_t":7.8678131103516e-06,
  "statperf.spaces_t":0.00010204315185547,
  "statperf.spaces":0.000103,
  "statperf.stats":5.4999999999999e-05,
  
  //
  // Number of packets passed via network interface
  "stat.net.received.total":0,
  "stat.net.received.rps":0,
  // Same, but sent via network interface
  "stat.net.sent.total":0,
  "stat.net.sent.rps":0,

}
```

### `$ tnt_check.sh`
grep all tarantool@* instances and check parameters:
 * box.slab.info().arena_used_ratio
 * box.info().status
 * replication status

*Returns*:

 - empty result on success
 - `error(reason)` on error

### `$ tnt_collectd.sh`
grep all tarantool@* instances, perform require('stat').stat() and generate putval statements

*Returns*:

 - list of metrics on success
 - `error(reason)` on error
 
 Example

``` 
$ tnt_collectd.sh
```

```

PUTVAL "host/tarantool/tarantool-slab_arena_size" interval=1 N:7483488
PUTVAL "host/tarantool/tarantool-space_chat_bsize" interval=1 N:38774
PUTVAL "host/tarantool/tarantool-statperf_fibers_t" interval=1 N:0.039196491241455
PUTVAL "host/tarantool/tarantool-stat_net_received" interval=1 N:125297500
PUTVAL "host/tarantool/tarantool-space_question_bsize" interval=1 N:7670
PUTVAL "host/tarantool/tarantool-stat_op_update" interval=1 N:23988
...
```


# See Also

 * [Tarantool][]

[Tarantool]: http://github.com/tarantool/tarantool
