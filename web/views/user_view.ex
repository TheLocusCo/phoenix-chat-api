defmodule PhoenixChat.UserView do
  use PhoenixChat.Web, :view

  alias PhoenixChat.{UserView}

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user, token: token}) do
    %{data: render_one(user, UserView, "user_token.json", token: token)}
  end

  def render("show.json", %{user: user, org: org}) do
    %{data: render_one(user, UserView, "user_organization.json", org: org)}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{email: user.email,
      id: user.id,
      username: user.username}
  end

  def render("user_token.json", %{user: user, token: token}) do
    %{email: user.email,
      id: user.id,
      token: token,
      username: user.username}
  end

  def render("user_organization.json", %{user: user, org: org}) do
    %{email: user.email,
      id: user.id,
      username: user.username,
      website: org.website,
      public_key: org.public_key}
  end
end
