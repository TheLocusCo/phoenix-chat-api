defmodule PhoenixChat.Organization do
  use PhoenixChat.Web, :model

  schema "organizations" do
    field :public_key, :string
    field :website, :string
    belongs_to :owner, PhoenixChat.Owner

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:website])
    |> validate_required([:website])
    |> update_change(:website, &set_uri_scheme/1)
    |> validate_change(:website, &validate_website/2)
    |> unique_constraint(:website)
    |> put_public_key()
    |> unique_constraint(:public_key)
  end

  defp put_public_key(%{data: data} = changeset) do
    if changeset.valid? && !data.id do
      changeset
      |> put_change(:public_key, random_key())
    else
      changeset
    end
  end

  defp random_key(length \\ 10) do
    :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
  end

  defp set_uri_scheme(nil), do: nil
  defp set_uri_scheme(website) do
    if Regex.match?(~r/^\w+:\/\//, website) do
      website
    else
      "https://" <> website
    end |> String.downcase()
  end

  defp validate_website(:website, website) do
    %URI{scheme: scheme, host: host} = URI.parse(website)

    if is_nil(scheme) ||
       is_nil(host) ||
       not scheme in ~w(http https) ||
       !valid_host_format?(host) do
      [website: "invalid url format"]
    else
      []
    end
  end

  defp valid_host_format?(host) do
    Regex.match? ~r/^([a-zA-z]+\.)*[a-zA-Z]+$/, host
  end
end
