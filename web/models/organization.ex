defmodule PhoenixChat.Organization do
  use PhoenixChat.Web, :model
  alias PhoenixChat.{User, Repo}

  schema "organizations" do
    field :public_key, :string
    field :website, :string

    has_many  :admins, User, foreign_key: :organization_id
    belongs_to :owner, User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}, association \\ false) do
    required_fields = if association, do: [:website], else: [:website, :owner_id]

    struct
    |> cast(params, [:website, :owner_id])
    |> validate_required(required_fields)
    |> validate_change(:owner_id, &validate_new_owner_admin/2)
    |> update_change(:website, &set_uri_scheme/1)
    |> validate_change(:website, &validate_website/2)
    |> unique_constraint(:website)
    |> put_public_key()
    |> unique_constraint(:public_key)
  end

  @doc """
  User for `cast_assoc/2` in `User.registration_changeset/2`. It's only difference
  from `changeset/3` is that it does not require an `owner_id`.
  """
  def owner_changeset(struct, params \\ %{}) do
    changeset(struct, params, true)
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

  defp validate_new_owner_admin(:owner_id, owner_id) do
    user = Repo.get! User, owner_id
    org = Repo.preload(user, :organization).organization || Repo.preload(user, :owned_organization).owned_organization

    if org do
      [owner_id: "user is owner or admin of existing organization"]
    else
      []
    end
  end
end
