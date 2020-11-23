defmodule PlanningPoker.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def change do
    create table(:tables) do
      add :table_name, :string
      add :code, :string
      add :show_vote, :boolean
      add :users, :map
      add :voting_rule, :string, default: "0, 1, 2, 3, 5, 8, 13, 21"
      add :countdown, :integer, default: 30
      add :countdown_ending, :utc_datetime

      timestamps()
    end

  end
end
