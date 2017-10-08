defmodule PhoenixChat.RoomChannel do
  use PhoenixChat.Web, :channel
  require Logger

  alias PhoenixChat.{Message, Repo}

  def join("room:" <> room_id, payload, socket) do
    authorize(payload, fn ->
      messages = room_id
        |> Message.latest_room_messages
        |> Repo.all
        |> Enum.reverse
      {:ok, %{messages: messages}, socket}
    end)
  end

  def handle_in("message", payload, socket) do
    Logger.info("Posting message...#{inspect socket.assigns}")
    payload = payload
      |> Map.put("user_id", socket.assigns[:user_id])
      |> Map.put("anonymous_user_id", socket.assigns[:uuid])
    Logger.info("Payload...#{inspect payload}")
    changeset = Message.changeset(%Message{}, payload)

    case Repo.insert(changeset) do
      {:ok, message} ->
        broadcast! socket, "message", message
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end
end
