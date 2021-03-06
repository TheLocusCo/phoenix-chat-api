defmodule PhoenixChat.AdminChannel do
  @moduledoc """
  The channel used to give the administrator access to all users.
  """

  use PhoenixChat.Web, :channel
  require Logger

  alias PhoenixChat.{Presence, Repo, AnonymousUser, LobbyList}

  intercept ~w(lobby_list)

  @doc """
  The `admin:active_users` topic is how we identify all users currently using the app.
  """
  # def join("admin:active_users", payload, socket) do
  #   Logger.info("Join::uuid::#{socket.assigns[:uuid]}::user_id::#{socket.assigns[:user_id]}::assigns::#{inspect socket.assigns}")
  #   authorize(payload, fn ->
  #     send(self, :after_join)
  #     id = socket.assigns[:uuid] || socket.assigns[:user_id]
  #     {:ok, %{id: id, lobby_list: admin_lobby_list}, socket}
  #   end)
  # end

  def join("admin:active_users", payload, socket) do
    authorize(payload, fn ->
      send(self, :after_join)

      public_key = socket.assigns.public_key
      lobby_list = LobbyList.lookup(public_key)
      {:ok, %{lobby_list: lobby_list}, socket}
    end)
  end

  def handle_info(:after_join, socket) do
    %{assigns: assigns} = socket
    id = assigns.user_id || assigns.uuid

    # Keep track of rooms to be displayed to admins
    LobbyList.insert(assigns.public_key, id)
    broadcast! socket, "lobby_list", %{uuid: id, public_key: assigns.public_key}

    # Keep track of users that are online
    push socket, "presence_state", Presence.list(socket)
    {:ok, _} = Presence.track(socket, id, %{
        online_at: inspect(System.system_time(:seconds))
      })
    {:noreply, socket}
  end

  @doc """
  This handles the `:after_join` event and tracks the presence of the socket that
  has subscribed to the `admin:active_users` topic.
  """

  # def handle_info(:after_join, %{assigns: %{uuid: uuid}} = socket) do
  #   Logger.info "Preparing to save user for: #{uuid}"
  #   user = ensure_user_saved!(uuid)

  #   broadcast! socket, "lobby_list", user

  #   push socket, "presence_state", Presence.list(socket)
  #   Logger.info "Presence for socket: #{inspect socket}"
  #   {:ok, _} = Presence.track(socket, uuid, %{
  #     online_at: inspect(System.system_time(:seconds))
  #   })
  #   {:noreply, socket}
  # end

  def handle_out("lobby_list", payload, socket) do
    %{assigns: assigns} = socket
    if assigns.user_id && assigns.public_key == payload.public_key do
      push socket, "lobby_list", payload
    end
    {:noreply, socket}
  end

  @doc """
  Sends the lobby_list only to admins
  """
  def handle_out("lobby_list", payload, socket) do
    assigns = socket.assigns
    if assigns[:user_id] do
      push socket, "lobby_list", payload
    end
    {:noreply, socket}
  end

  def admin_lobby_list do
    AnonymousUser.recently_active_users |> Repo.all
  end

  defp ensure_user_saved!(uuid) do
    user_exists = Repo.get(AnonymousUser, uuid)
    if user_exists do
      user_exists
    else
      changeset = AnonymousUser.changeset(%AnonymousUser{}, %{id: uuid})
      Repo.insert!(changeset)
    end
  end
end
