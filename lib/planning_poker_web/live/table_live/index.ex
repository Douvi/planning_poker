require Logger

defmodule PlanningPokerWeb.TableLive.Index do
  use PlanningPokerWeb, :live_view

  alias PlanningPoker.Planning
  alias PlanningPoker.Planning.Table

  @impl true
  def mount(_params, %{"_csrf_token" => key}, socket) do
    {:ok, socket
      |> assign(:user_key, key)
      |> assign(:tables, list_tables())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Table")
    |> assign(:table, Planning.get_table!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Table")
    |> assign(:table, %Table{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tables")
    |> assign(:table, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    table = Planning.get_table!(id)
    {:ok, _} = Planning.delete_table(table)

    {:noreply, assign(socket, :tables, list_tables())}
  end

  defp list_tables do
    Planning.list_tables()
  end
end
