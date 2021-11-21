defmodule HighlineTest do
  use ExUnit.Case
  doctest Highline

  test "greets the world" do
    assert Highline.hello() == :world
  end
end
