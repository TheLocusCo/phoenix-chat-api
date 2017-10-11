defmodule PhoenixChat.Repo.Migrations.CreateOrganization do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :public_key, :string, null: false
      add :website, :string, null: false
      add :owner_id, references(:users, on_delete: :nilify_all)

      timestamps()
    end

    create index(:organizations, [:owner_id])
    create unique_index(:organizations, [:public_key])
    create unique_index(:organizations, [:website])
  end
end
