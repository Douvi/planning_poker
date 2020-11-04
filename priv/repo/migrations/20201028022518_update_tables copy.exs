defmodule PandaPhoenix.Repo.Migrations.UpdateFieldPrivateMessage do
  use Ecto.Migration

  def up do
    execute """
      ALTER TABLE ONLY tables ALTER COLUMN countdown SET DEFAULT 30;
    """
  end
end
