defmodule ZfsMonitor.MixProject do
  use Mix.Project

  def project do
    [
      app: :zfs_monitor,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ZFSMonitor.Application, []}
    ]
  end

  defp aliases do
    [
      "protobuf.generate": ["cmd protoc --elixir_out=plugins=grpc:./lib --proto_path=priv/protos priv/protos/*.proto"]
    ]
  end

  defp deps do
    [
      {:grpc, "~> 0.7"},
      {:protobuf, "~> 0.12"} 
    ]
  end
end
