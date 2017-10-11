defmodule PhoenixChat.OrganizationTest do
  use PhoenixChat.ModelCase

  alias PhoenixChat.Organization

  @valid_attrs %{website: "foo.com"}
  @invalid_attrs %{}

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
    changeset = Organization.changeset(%Organization{}, %{website: "http://foo.com"})
    org1 = Repo.insert! changeset

    changeset = Organization.changeset(%Organization{}, %{website: "http://bar.com"})
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
      changeset = Organization.changeset(%Organization{}, %{website: valid_url})

      assert changeset.valid?
    end
  end
end
