defmodule PlanningPoker.Planning.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :id
    field :user_name
    field :vote
    timestamps()
  end

  @doc false
  def changeset(table, attrs) do
    table
    |> cast(attrs, [:user_name, :id, :vote])
    |> validate_required([:user_name, :id])
  end

  def to_map(%{"id" => id, "user_name" => user_name}), do: %{id: id, user_name: user_name}
  def to_map(user), do: %{id: user.id, inserted_at: user.inserted_at, updated_at: user.updated_at, user_name: user.user_name, vote: user.vote}

end
