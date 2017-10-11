defmodule PhoenixChat.OrganizationTest do
  use PhoenixChat.ModelCase
  require Logger
  alias PhoenixChat.{Organization, ConnCase, Repo}

  @valid_attrs %{website: "foo.com", owner_id: 1}
  @invalid_attrs %{}

  setup do
    user = ConnCase.create_user!(%{id: 1})
    {:ok, %{user: user}}
  end

  test "organization belongs to owner", %{user: user} do
    org = Repo.insert! %Organization{website: "foo.com", owner_id: user.id, public_key: "test"}
          |> Repo.preload(:owner)

    assert org.owner == user
  end

  test "organization can have one admin" do
    org  = Repo.insert! %Organization{website: "foo.com", public_key: "test"}
    user = ConnCase.create_user!(%{username: "bar", email: "bar@foo.com", organization_id: org.id})

    org = Repo.preload(org, :admins)

    assert org.admins == [user]
  end

  test "organization has many admins" do
    org = Repo.insert! %Organization{website: "foo.com", public_key: "test"}
    user = ConnCase.create_user!(%{username: "bar", email: "bar@foo.com", organization_id: org.id})
    user2 = ConnCase.create_user!(%{username: "baz", email: "baz@qux.com", organization_id: org.id})

    org = Repo.preload(org, :admins)

    assert org.admins == [user, user2]
  end

  test "changeset with valid attributes" do
    changeset = Organization.changeset(%Organization{}, @valid_attrs)

    assert changeset.valid?
  end

  test "changeset must have unique website" do
    changeset = Organization.changeset(%Organization{}, @valid_attrs)
    Repo.insert! changeset

    changeset = Organization.changeset(%Organization{}, @valid_attrs)
    {:error, changeset} = Repo.insert(changeset)

    assert {:website, {"has already been taken", []}} in changeset.errors
  end

  test "changeset must have a unique public key generated on create" do
    changeset = Organization.changeset(%Organization{}, %{website: "http://foo.com", owner_id: 1})
    org1 = Repo.insert! changeset

    changeset = Organization.changeset(%Organization{}, %{website: "http://bar.com", owner_id: 1})
    org2 = Repo.insert! changeset

    assert org1.public_key != org2.public_key
  end

  test "changeset's website must be a valid url" do
    some_invalid_urls = ["test this", "???", "...", ".www.foo.bar.", "foo.", "ftp://foo.com"]

    for invalid_url <- some_invalid_urls do
      changeset = Organization.changeset(%Organization{}, %{website: invalid_url})

      assert {:website, {"invalid url format", []}} in changeset.errors
    end

    some_valid_urls = ~w(foo.com www.foo.com http://foo.com https://foo.com?test=foo foo.com?test=bar)

    for valid_url <- some_valid_urls do
      changeset = Organization.changeset(%Organization{}, %{website: valid_url, owner_id: 1})

      assert changeset.valid?
    end
  end
end
