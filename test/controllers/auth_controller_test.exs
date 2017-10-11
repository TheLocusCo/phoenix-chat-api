defmodule PhoenixChat.AuthControllerTest do
  use PhoenixChat.ConnCase

  alias PhoenixChat.User
  @valid_attrs %{email: "me@test.com", password: "password", username: "test"}
  @invalid_attrs %{}

  setup do
    {:ok, conn: put_req_header(build_conn, "accept", "application/json")}
  end

  describe "post '/auth/identity/callback'" do
    test "successful authentication returns JWT token", %{conn: conn} do
      user = User.registration_changeset(%User{}, @valid_attrs) |> Repo.insert!
      params = %{email: user.email, password: "password"}
      conn = post conn, "/auth/identity/callback", params

      response = json_response(conn, 201)["data"]
      assert response

      assert %{"username" => "test", "token" => token, "email" => "me@test.com"} = response
      assert {:ok, claims} = Guardian.decode_and_verify(token)
      assert claims["sub"] == "User:#{user.id}"
    end

    test "unsuccessful authentication", %{conn: conn} do
      params = %{email: "non@existent.com", password: "password"}
      conn = post conn, "/auth/identity/callback", params

      assert json_response(conn, 400) == "Internal server error"
    end
  end

  describe "get '/auth/me'" do
    test "authorized user gets json response", %{conn: conn} do
      user = User.registration_changeset(%User{}, @valid_attrs) |> Repo.insert!
      token = conn
              |> Guardian.Plug.api_sign_in(user)
              |> Guardian.Plug.current_token

      conn = conn
             |> put_req_header("authorization", "Bearer #{token}")
             |> get("/auth/me")

      response = json_response(conn, 200)["data"]
      assert response

      %{email: email, id: id, username: username} = user
      assert %{"email" => ^email, "id" => ^id, "username" => ^username} = response
    end

    test "unauthorized user", %{conn: conn} do
      conn = conn
             |> put_req_header("authorization", "Bearer fake_token")
             |> get("/auth/me")

      assert json_response(conn, 401) == "Internal server error"
    end
  end
end
