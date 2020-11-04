defmodule PandaPhoenix.Repo.Migrations.UpdateFieldPrivateMessage do
  use Ecto.Migration

  def up do
    alter table(:tables) do
      add :voting_rule, :string
      add :countdown, :integer
    end
  end
end
