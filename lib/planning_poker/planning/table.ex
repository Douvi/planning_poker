require Logger

defmodule PlanningPoker.Planning.Table do
  use Ecto.Schema
  import Ecto.Changeset
  alias PlanningPoker.Planning.User

  schema "tables" do
    field :table_name, :string
    field :code, :string
    field :show_vote, :boolean, default: false
    embeds_many :users, User, on_replace: :delete
    timestamps()
  end

  @doc false
  def changeset(table, attrs) do
    old_users =
      if table.users do
        table.users |> Enum.map(fn user -> User.to_map(user) end)
      else
        []
      end

    attrs = case attrs do
     %{"id" => id, "user_name" => user_name} -> %{users: old_users ++ [User.to_map(%{"id" => id,"user_name" => user_name})]}
     %{users: []} -> attrs
     %{users: users} -> %{attrs | users: Enum.map(users, fn user -> User.to_map(user) end)}
     _ -> attrs
    end

    table
    |> cast(attrs, [:table_name, :code, :show_vote])
    |> cast_embed(:users)
    |> validate_required([:table_name, :show_vote])
  end
end
