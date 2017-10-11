defmodule PhoenixChat.ChannelHelpersTest do
  use ExUnit.Case

  import PhoenixChat.ChannelHelpers

  test "authorize/2 and authorize/3" do
    assert authorize("test", fn -> "foo" end) == "foo"

    failed_authorization = authorize("test", fn -> "foo" end, fn _ -> false end)
    assert {:error, %{reason: "unauthorized"}} == failed_authorization
  end

  test "authorized?/1" do
    assert authorized?(false) == true
  end
end
