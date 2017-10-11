defmodule PhoenixChat.ChannelCase do
  @moduledoc """
  This module defines the test case to be used by
  channel tests.

  Such tests rely on `Phoenix.ChannelTest` and also
  import other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  alias PhoenixChat.{Repo, AnonymousUser}

  using do
    quote do
      # Import conveniences for testing with channels
      use Phoenix.ChannelTest

      alias PhoenixChat.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import PhoenixChat.ChannelCase
      # The default endpoint for testing
      @endpoint PhoenixChat.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(PhoenixChat.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(PhoenixChat.Repo, {:shared, self()})
    end

    :ok
  end

  def create_anon_user!() do
    Repo.insert! %AnonymousUser{id: "3c8c40ad-68bf-4e4a-9627-9ebddd2431e2"}
  end

  def create_anon_user!(attrs) do
    map = Map.merge(%{id: "3c8c40ad-68bf-4e4a-9627-9ebddd2431e2"}, attrs)
    struct = struct(AnonymousUser, map)
    Repo.insert! struct
  end
end
