defmodule GraphqlExample.Repo.Migrations.CreateFeatures do
  use Ecto.Migration

  def change do
    create table(:features) do
      add :name, :string
      add :thing_id, references(:things, on_delete: :nothing)

      timestamps()
    end

    create index(:features, [:thing_id])
  end
end
