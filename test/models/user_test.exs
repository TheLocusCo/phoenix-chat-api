defmodule PhoenixChat.UserTest do
  use PhoenixChat.ModelCase

  alias PhoenixChat.{User, Organization, ConnCase, Repo}

  @valid_attrs %{email: "me@test.com", password: "some password", username: "some username"}
  @invalid_attrs %{}

  test "user can own an organization" do
    user = ConnCase.create_user!
    org  = Repo.insert! %Organization{website: "foo.com", owner_id: user.id, public_key: "test"}
    user = Repo.preload(user, :owned_organization)

    assert user.owned_organization == org
  end

  test "user belongs to organization" do
    org  = Repo.insert! %Organization{website: "foo.com", public_key: "test"}
    user = ConnCase.create_user!(%{organization_id: org.id})
           |> Repo.preload(:organization)

    assert user.organization == org
  end

  test "changeset with valid attributes" do
    changeset = User.registration_changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with blank email and username" do
    %{errors: errors} = User.changeset(%User{}, %{})
    assert {:email, {"can't be blank", [validation: :required]}} in errors
    assert {:username, {"can't be blank", [validation: :required]}} in errors
  end

  test "changeset with invalid email format" do
    %{errors: errors} = User.changeset(%User{}, %{email: "foo", username: "test"})
    assert {:email, {"has invalid format", [validation: :format]}} in errors
  end

  test "changeset with username invalid length" do
    long_username = String.duplicate "f", 21
    %{errors: errors} = User.changeset(%User{}, %{username: long_username})
    assert {:username, {"should be at most %{count} character(s)", [count: 20, validation: :length, max: 20]}} in errors
  end

  test "changeset must have a unique email" do
    changeset = User.changeset(%User{}, @valid_attrs)
    Repo.insert!(changeset)

    changeset = User.changeset(%User{}, @valid_attrs)
    {:error, changeset} = Repo.insert(changeset)
    assert {:email, {"has already been taken", []}} in changeset.errors
  end

  test "changeset must have a unique username" do
    changeset = User.changeset(%User{}, @valid_attrs)
    Repo.insert!(changeset)

    attrs = Map.put(@valid_attrs, :email, "test@bar.com")
    changeset = User.changeset(%User{}, attrs)
    {:error, changeset} = Repo.insert(changeset)
    assert {:username, {"has already been taken", []}} in changeset.errors
  end

  test "registration changeset with valid attributes" do
    valid_attrs = Map.put(@valid_attrs, :password, "password")
    changeset = User.registration_changeset(%User{}, valid_attrs)
    assert changeset.valid?
    assert get_change(changeset, :encrypted_password)
  end

  test "registration changeset with invalid password length" do
    long_password = String.duplicate "p", 101
    %{errors: errors} = User.registration_changeset(%User{}, %{password: long_password})
    assert {:password, {"should be at most %{count} character(s)", [count: 100, validation: :length, max: 100]}} in errors
  end
end
