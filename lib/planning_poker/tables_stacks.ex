defmodule PlanningPoker.TablesStack do
  use GenServer

  # Client

  def start_link(default \\ []) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def push(%{table_id: id, user: user}) do
    GenServer.cast(__MODULE__, {:push, %{table_id: id, user: user}})
  end

  def pop(%{table_id: id, user_key: user_key}) do
    GenServer.call(__MODULE__, {:pop, %{table_id: id, user_key: user_key}})
  end

  def find(%{table_id: id, user_key: user_key}) do
    GenServer.call(__MODULE__, {:find, %{table_id: id, user_key: user_key}})
  end

  # Server (callbacks)
  @impl true
  def init(stack) do
    {:ok, stack}
  end

  @impl true
  def handle_call({:pop, %{table_id: id, user_key: user_key}}, _from, state) do
    newState = Enum.filter(state, fn e -> e.table_id != id and e.user.id != user_key end)
    element = Enum.filter(state, fn e -> e.table_id == id and e.user.id == user_key end)
    {:reply, element, newState}
  end

  @impl true
  def handle_call({:find, %{table_id: id, user_key: user_key}} = param, _from, state) do
    IO.puts("find -> param : #{inspect(param)}")
    IO.puts("find -> state : #{inspect(state)}")
    element = Enum.filter(state, fn e -> e.table_id == id and e.user.id == user_key end)
    IO.puts("find -> element : #{inspect(element)}")
    {:reply, element, state}
  end

  @impl true
  def handle_cast({:push, new_element}, state) do
    {:noreply, [new_element | state]}
  end
end
