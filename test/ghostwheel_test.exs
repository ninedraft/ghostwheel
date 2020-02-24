defmodule GhostwheelTest do
  use ExUnit.Case
  doctest Ghostwheel

  test "greets the world" do
    assert Ghostwheel.hello() == :world
  end
end
