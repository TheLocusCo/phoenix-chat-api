defmodule PhoenixChat.AdminChannelTest do
  use PhoenixChat.ChannelCase

  alias PhoenixChat.{AdminChannel, LobbyList}

  test "joining admin:active_users as admin" do
    # create_anon_user!
    # create_anon_user!(%{id: "42886caa-6903-46e3-be36-e1d364853473"})
    LobbyList.insert("pub_key", "3c8c40ad-68bf-4e4a-9627-9ebddd2431e2")
    LobbyList.insert("pub_key", "42886caa-6903-46e3-be36-e1d364853473")

    {:ok, %{lobby_list: lobby_list}, _socket} =
      socket("user_id", %{user_id: 1, public_key: "pub_key"})
      |> subscribe_and_join(AdminChannel, "admin:active_users")

    assert length(lobby_list) == 2
    assert_push "lobby_list", %{uuid: 1}
    assert_push "presence_state", %{}
    assert_push "presence_diff", %{joins: %{"1" => %{}}}
  end

  test "non-admin users do not receive the 'lobby_list' event on join" do
    {:ok, %{lobby_list: _}, _} =
      socket("user_id", %{user_id: nil, uuid: "42886caa-6903-46e3-be36-e1d364853473", public_key: "pub_key"})
      |> subscribe_and_join(AdminChannel, "admin:active_users")

    refute_push "lobby_list", %{}
  end
end
