defmodule GitlabCliTest do
  use ExUnit.Case
  doctest GitlabCli

  test "greets the world" do
    assert GitlabCli.hello() == :world
  end
end
