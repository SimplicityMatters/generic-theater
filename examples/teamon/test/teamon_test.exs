defmodule TeamonTest do
  use ExUnit.Case
  doctest Teamon

  test "greets the world" do
    assert Teamon.hello() == :world
  end
end
