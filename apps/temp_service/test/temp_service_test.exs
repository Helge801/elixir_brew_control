defmodule TempServiceTest do
  use ExUnit.Case
  doctest TempService

  test "greets the world" do
    assert TempService.hello() == :world
  end
end
