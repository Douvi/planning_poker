require Logger

defmodule PlanningPoker.Planning do
  @moduledoc """
  The Planning context.
  """

  import Ecto.Query, warn: false
  alias PlanningPoker.Repo

  alias PlanningPoker.Planning.Table
  alias PlanningPoker.Planning.User
  use Timex

  @doc """
  Returns the list of tables.

  ## Examples

      iex> list_tables()
      [%Table{}, ...]

  """
  def list_tables do
    Repo.all(from t in Table, order_by: [desc: t.id])
  end

  @doc """
  Gets a single table.

  Raises `Ecto.NoResultsError` if the Table does not exist.

  ## Examples

      iex> get_table!(123)
      %Table{}

      iex> get_table!(456)
      ** (Ecto.NoResultsError)

  """
  def get_table!(id, lock \\ false) do
    table = case lock do
      true -> Repo.get!(Table, id, lock: "FOR UPDATE")
      false -> Repo.get!(Table, id)
    end
    list = Enum.sort_by(table.users, &(&1.inserted_at))

    %Table{table | users: list}
  end

  @doc """
  Creates a table.

  ## Examples

      iex> create_table(%{field: value})
      {:ok, %Table{}}

      iex> create_table(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_table(attrs \\ %{}) do
    %Table{}
    |> Table.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:table_created)
  end

  @doc """
  Updates a table.

  ## Examples

      iex> update_table(table, %{field: new_value})
      {:ok, %Table{}}

      iex> update_table(table, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_table(%Table{} = table, attrs) do
    table
    |> Table.changeset(attrs)
    |> Repo.update()
    |> broadcast(:table_updated)
  end

  @doc """
  Add a user.

  ## Examples

      iex> update_table(table, %{field: new_value})
      {:ok, %Table{}}

      iex> update_table(table, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def add_user(%Table{} = table, attrs) do
    get_table!(table.id, true)
    |> update_table(attrs)
  end

  def get_user!(%{"id" => id, "user_key" => user_key}) do
    case Ecto.Adapters.SQL.query(PlanningPoker.Repo, "SELECT users.id, users.user_name, users.is_guest  FROM tables AS t0, jsonb_to_recordset(t0.users) as users(id text, user_name text, is_guest boolean) WHERE (t0.id = #{id}) AND users.id = '#{user_key}'", []) do
      {:ok, result} ->
        case result_to_maps(result) do
          [] ->
            case PlanningPoker.TablesStack.find(%{table_id: id, user_key: user_key}) do
              [] -> %User{}
              [head | _tail] -> head
            end
          [head | _tail] ->
            head
        end
      {:error, _} -> false
    end
  end

  defp result_to_maps(%Postgrex.Result{columns: _, rows: nil}), do: []

  defp result_to_maps(%Postgrex.Result{columns: col_nms, rows: rows}), do: Enum.map(rows, &Repo.load(User, {col_nms, &1}))

  def find_user(%{"id" => id, "user_key" => user_key}) do
    case Ecto.Adapters.SQL.query(PlanningPoker.Repo, "SELECT t0.id, users.id  FROM tables AS t0, jsonb_to_recordset(t0.users) as users(id text) WHERE (t0.id = #{id}) AND users.id = '#{user_key}'", []) do
      {:ok, result} ->
        if length(result.rows) == 0 do
          # let double check if user not into a GenServer
          case PlanningPoker.TablesStack.pop(%{table_id: id, user_key: user_key}) do
            [] -> false
            [header | _tail] ->
              table = get_table!(id, true)
              update_table(table, %{users: [header.user | table.users]})
              true
          end
        else
          # this mean length(result.rows) > 0
          true
        end
      {:error, _} -> false
    end
  end

  def delete_user(%{"id" => id, "user_key" => user_key}) do
    table = get_table!(id, true)
    attrs = Enum.filter(table.users, fn user ->
      if user.id == user_key do
        PlanningPoker.TablesStack.push(%{table_id: id, user: user})
        false
      else
        true
      end
    end)

    update_table(table, %{users: attrs})
  end

  @doc """
  Deletes a table.

  ## Examples

      iex> delete_table(table)
      {:ok, %Table{}}

      iex> delete_table(table)
      {:error, %Ecto.Changeset{}}

  """
  def delete_table(%Table{} = table) do
    Repo.delete(table)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking table changes.

  ## Examples

      iex> change_table(table)
      %Ecto.Changeset{data: %Table{}}

  """
  def change_table(%Table{} = table, attrs \\ %{}) do
    Table.changeset(table, attrs)
  end

  def show_vote!(id) do
    id
    |> get_table!(true)
    |> update_table(%{show_vote: true})
  end

  def reset_vote!(id) do
    table = id
    |> get_table!(true)

    users = Enum.map(table.users, fn %User{vote: _}=user ->
      %User{user| vote: nil}
    end)

    table
    |> update_table(%{users: users, show_vote: false, countdown_ending: nil})
  end

  def start_countdown!(id) do
    table = id
      |> get_table!(true)

    table
      |> update_table(%{countdown_ending: DateTime.add(DateTime.utc_now, table.countdown)})
  end

  def stop_countdown!(id) do
    table = id
      |> get_table!(true)

    table
      |> update_table(%{countdown_ending: nil})
  end

  def apply_vote!(id, user_key, new_vote) do
    table = id
    |> get_table!(true)

    users = Enum.map(table.users, fn %User{id: id}=user ->
      if id == user_key do
        %User{user| vote: new_vote}
      else
        user
      end
    end)

    show_vote = Enum.all?(users, fn %User{vote: vote} -> vote != nil end)

    countdown_ending = if show_vote do
      nil
    else
      table.countdown_ending
    end


    table
    |> update_table(%{users: users, show_vote: show_vote, countdown_ending: countdown_ending})
  end

  def subscribe(table_id) do
    Phoenix.PubSub.subscribe(PlanningPoker.PubSub, "table_#{table_id}")
  end
  def subscribe() do
    Phoenix.PubSub.subscribe(PlanningPoker.PubSub, "tables")
  end

  defp broadcast({:error, _reason} = error, _event), do: error
  defp broadcast({:ok, table}, event) do
    Phoenix.PubSub.broadcast(PlanningPoker.PubSub, "table_#{table.id}", {event, table})
    Phoenix.PubSub.broadcast(PlanningPoker.PubSub, "tables", {event, table})
    {:ok, table}
  end

end
