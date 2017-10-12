defmodule PhoenixChat.LobbyList do
  use GenServer

  require Logger

  @table :lobby_list

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: :lobby_list)
  end

  @doc """
  Create an :ets table for this module. We set the `:bag` option so that we can
  store multiple values with the same keys.
  """
  def init(:ok) do
    opts = [:public, :named_table, {:write_concurrency, true}, {:read_concurrency, false}, :bag]
    :ets.new(@table, opts)
    {:ok, %{}}
  end

  def insert(public_key, uuid) do
    :ets.insert(@table, {public_key, uuid})
  end

  def delete(public_key) do
    :ets.delete(@table, public_key)
  end

  def lookup(public_key) do
    @table
    |> :ets.lookup(public_key)
    |> Enum.map(fn {_, uuid} -> uuid end)
  end
end
