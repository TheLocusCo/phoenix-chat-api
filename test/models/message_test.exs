defmodule PhoenixChat.MessageTest do
  use PhoenixChat.ModelCase

  alias PhoenixChat.Message

  @valid_attrs %{body: "some body", from: "some from", room: "some room", timestamp: ~N[2010-04-17 14:00:00.000000]}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Message.changeset(%Message{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Message.changeset(%Message{}, @invalid_attrs)
    refute changeset.valid?
  end
end
