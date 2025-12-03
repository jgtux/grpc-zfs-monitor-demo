defmodule ZfsMonitorTest do
  use ExUnit.Case
  doctest ZfsMonitor

  test "greets the world" do
    assert ZfsMonitor.hello() == :world
  end
end
