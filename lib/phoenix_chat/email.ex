defmodule PhoenixChat.Email do
  use Bamboo.Phoenix, view: PhoenixChat.EmailView

  alias PhoenixChat.{User}

  def welcome_email(%User{email: email}) do
    new_email
    |> to(email)
    |> from("no-reply@phoenixchat.io")
    |> subject("Welcome")
    |> text_body("Welcome to PhoenixChat!")
  end
end
