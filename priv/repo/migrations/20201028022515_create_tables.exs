defmodule PlanningPoker.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def change do
    create table(:tables) do
      add :table_name, :string
      add :code, :string
      add :users, :map

      timestamps()
    end

  end
end
