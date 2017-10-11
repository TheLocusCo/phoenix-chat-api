defmodule PhoenixChat.UserControllerTest do
  require IEx
  use PhoenixChat.ConnCase

  alias PhoenixChat.User
  @valid_attrs %{email: "me@test.com", password: "some content", username: "some username"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end
  
  # Non default tests below

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(User, Map.drop(@valid_attrs, [:password]))
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    user = create_user!
    conn = put conn, user_path(conn, :update, user), user: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(User, Map.drop(@valid_attrs, [:password]))
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = create_user!
    conn = put conn, user_path(conn, :update, user), user: %{email: "foo"}
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    user = create_user!
    conn = delete conn, user_path(conn, :delete, user)
    assert response(conn, 204)
    refute Repo.get(User, user.id)
  end
end
