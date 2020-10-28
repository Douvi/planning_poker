defmodule PlanningPoker.Planning.Table do
  use Ecto.Schema
  import Ecto.Changeset
  alias PlanningPoker.Planning.User

  schema "tables" do
    field :table_name, :string
    field :code, :string
    embeds_many :users, User
    timestamps()
  end

  @doc false
  def changeset(table, attrs) do
    table
    |> cast(attrs, [:table_name, :code])
    |> cast_embed(:users)
    |> validate_required([:table_name])
  end
end
