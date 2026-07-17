# ZfsMonitor

A gRPC service, written in Elixir, that exposes live ZFS pool statistics over the network.

## What it does

`ZFSMonitor.Application` starts a `GRPC.Server.Supervisor` on port `50051` alongside a `GenServer` cache (`ZFSMonitor.Cache`) that collects stats every 5 seconds in the background. The gRPC server (`ZFSMonitor.GRPC.Server`) just reads from that cache — it doesn't shell out on every request — falling back to a synchronous collection only on cold start.

Service definition (`priv/protos/zfs_monitor.proto`):

```proto
service ZFSMonitor {
  rpc GetStats(StatsRequest) returns (StatsResponse);
  rpc StreamStats(StatsRequest) returns (stream StatsResponse);
}
```

`GetStats` returns one snapshot. `StreamStats` polls the cache in a loop and pushes on the client-requested `interval_seconds` — note this only throttles *delivery*, the underlying collection still runs on its own fixed 5s cadence regardless of what a client asks for.

`StatsResponse` bundles per-pool stats (name, size/allocated/free bytes, capacity %, health, fragmentation, IO), ARC stats, and basic system info (hostname, ZFS version, uptime).

## What's real vs. stubbed

Being upfront about this rather than letting the `.proto` schema imply more than what's implemented:

| Field | Status |
|---|---|
| Pool name / size / allocated / free / capacity / health / fragmentation | **Real** — parsed from `zpool list -Hp -o name,size,alloc,free,cap,frag,health` |
| Hostname | **Real** — `System.cmd("hostname", [])` |
| ARC stats (size, hit/miss rate, hits, misses) | **Stubbed** — hardcoded zeros, no `arcstat`/kstat read |
| Per-pool IO stats (read/write ops and bytes) | **Stubbed** — hardcoded zeros, not sourced from `zpool iostat` |
| ZFS version | **Stubbed** — hardcoded `"N/A"` |
| Uptime | **Stubbed** — hardcoded `0` |

`get_pool_details` exists in `ZFSMonitor.GRPC.Server` but isn't declared in the `.proto` or the generated service — it's dead code, not a reachable RPC.

## Running it

Requires `zpool` and `hostname` on `PATH` — no ZFS pool needed to boot the app, but pool collection returns an empty list (logged as an error) if `zpool` isn't available.

```sh
mix deps.get
mix protobuf.generate   # regenerate lib/zfs_monitor.pb.ex from the .proto, if it changes
iex -S mix               # starts the supervision tree, gRPC server listening on :50051
```

## Dependencies

- [`grpc`](https://hex.pm/packages/grpc) ~> 0.7
- [`protobuf`](https://hex.pm/packages/protobuf) ~> 0.12
- Elixir ~> 1.17
