defmodule PlanningPoker.Repo.Migrations.UpdateTables do
  use Ecto.Migration

  def change do
    alter table(:tables) do
      add :is_guest, :boolean, default: false
    end
  end
end
