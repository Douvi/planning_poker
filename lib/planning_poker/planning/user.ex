defmodule PlanningPoker.Planning.User do
  use Ecto.Schema

  embedded_schema do
    field :name
    field :vote
    timestamps()
  end
end
