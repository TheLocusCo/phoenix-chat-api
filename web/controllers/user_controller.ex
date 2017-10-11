defmodule PhoenixChat.UserController do
  use PhoenixChat.Web, :controller
  require Logger

  alias PhoenixChat.{Email, Mailer, User}

  # def index(conn, _params) do
  #   users = Repo.all(User)
  #   render(conn, "index.json", users: users)
  # end

  # plug :scrub_params, "user" when action in [:create, :update]

  def create(conn, %{"user" => user_params}) do
    Logger.info("In pre error params #{inspect user_params}")
    changeset = User.registration_changeset(%User{}, user_params)
    Logger.info("In pre error changeset #{inspect changeset}")

    case Repo.insert(changeset) do
      {:ok, user} ->
        Logger.info("????")
        {:ok, token, _claims} = Guardian.encode_and_sign(user, :token)

        send_welcome_email(user)

        conn
        |> put_status(:created)
        |> render("show.json", user: user)
      {:error, changeset} ->
        Logger.info("In user error changeset #{inspect changeset}")
        conn
        |> put_status(:unprocessable_entity)
        |> render(PhoenixChat.ChangesetView, "error.json", changeset: changeset)
    end
  end

  # def show(conn, %{"id" => id}) do
  #   user = Repo.get!(User, id)
  #   render(conn, "show.json", user: user)
  # end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        render(conn, "show.json", user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(PhoenixChat.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    send_resp(conn, :no_content, "")
  end

  defp send_welcome_email(user) do
    user
    |> Email.welcome_email
    |> Mailer.deliver_later
  end
end
