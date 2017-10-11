defmodule PhoenixChat.UserTest do
  use PhoenixChat.ModelCase

  alias PhoenixChat.User

  @valid_attrs %{email: "me@test.com", password: "some password", username: "some username"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.registration_changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
