require Logger

defmodule PlanningPokerWeb.TableLive.Show do
  use PlanningPokerWeb, :live_view

  alias PlanningPoker.Planning

  @impl true
  def mount(%{"id" => id}, %{"_csrf_token" => key}, socket) do
    Logger.info("@@@@@@@@@@@@ mount -- user_key -> #{inspect(key)}")
    if connected?(socket), do: Planning.subscribe(id)

    {:ok, socket |> assign(:user_key, key)}
  end

  @impl true
  def handle_info({:table_updated, table}, socket) do
    {:noreply, socket |> assign(:table, table)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:table, Planning.get_table!(id))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:table, Planning.get_table!(id))
  end

  defp apply_action(socket, :join, %{"id" => id}) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:table, Planning.get_table!(id))
  end

  @impl true
  def handle_event(event, param, socket) do
    {:noreply, apply_event(socket, event, param)}
  end

  defp apply_event(socket, "show_vote", %{"id" => id}) do
    Planning.show_vote!(id)

    socket
     |> assign(:table, Planning.get_table!(id))
  end

  defp apply_event(socket, "reset_vote", %{"id" => id}) do
    Planning.reset_vote!(id)

    socket
     |> assign(:table, Planning.get_table!(id))
  end

  defp apply_event(socket, "apply_vote", %{"id" => new_vote}) do
    table_id = socket.assigns.table.id
    Planning.apply_vote!(table_id, socket.assigns.user_key, new_vote)

    socket
     |> assign(:table, Planning.get_table!(table_id))
  end

  defp page_title(:show), do: "Show Table"
  defp page_title(:edit), do: "Edit Table"
  defp page_title(:join), do: "Join Tables"

  def is_not_join!(%{"id" => id, "user_key" => user_key}) do
    !Planning.find_user(%{"id" => id, "user_key" => user_key})
  end

  @impl true
  def terminate(reason, socket) do
    Logger.info("@@@@@@@@@@@@ terminate -- user_key -> #{inspect(socket.assigns.user_key)} | reason -> #{inspect(reason)}")
    case reason do
      {:shutdown, :closed} ->
        Planning.delete_user(%{"id" => socket.assigns.table.id, "user_key" => socket.assigns.user_key})
        reason
      _ -> reason
    end
  end
end
