defmodule ZFSMonitor.Application do
  use Application

  def start(_type, _args) do
    children = [
      ZFSMonitor.Cache,
      {GRPC.Server.Supervisor,
       servers: [ZFSMonitor.GRPC.Server],
       port: 50051,
       start_server: true
      }
    ]


    opts = [strategy: :one_for_one, name: ZFSMonitor.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
