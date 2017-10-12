defmodule PhoenixChat.UserSocketTest do
  use PhoenixChat.ChannelCase

  alias PhoenixChat.{Repo, User, UserSocket}

  test "connecting to user socket as logged-in user" do
    admin = Repo.insert!(%User{email: "admin@bar.com", username: "admin"})

    {:ok, socket} = connect(UserSocket, %{"id" => admin.id, "public_key" => "pub_key"})
    {:ok, _, socket} = subscribe_and_join(socket, "room:1", %{})

    assert socket.assigns.user_id == admin.id
    assert socket.assigns.email == admin.email
    assert socket.assigns.username == admin.username
  end

  test "connecting to user socket as anonymous user" do
    {:ok, socket} = connect(UserSocket, %{"uuid" => 25, "public_key" => "pub_key"})
    {:ok, _, socket} = subscribe_and_join(socket, "room:25", %{})

    refute socket.assigns.user_id
    assert socket.assigns.uuid == 25
    assert socket.assigns.public_key == "pub_key"
  end
end
