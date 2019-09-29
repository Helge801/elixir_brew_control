defmodule RelayServiceTest do
  use ExUnit.Case
  doctest RelayService

  test "greets the world" do
    assert RelayService.hello() == :world
  end
end
