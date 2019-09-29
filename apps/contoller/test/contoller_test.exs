defmodule ContollerTest do
  use ExUnit.Case
  doctest Contoller

  test "greets the world" do
    assert Contoller.hello() == :world
  end
end
