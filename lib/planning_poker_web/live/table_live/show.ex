require Logger

defmodule PlanningPokerWeb.TableLive.Show do
  use PlanningPokerWeb, :live_view

  alias PlanningPoker.Planning

  @impl true
  def mount(_params, %{"_csrf_token" => key}, socket) do
    {:ok, socket |> assign(:user_key, key)}
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

  defp apply_event(socket, "apply_vote", %{"id" => id}) do
    # TODO APPLY VOTE

    socket
     |> assign(:table, Planning.get_table!(id))
  end

  defp page_title(:show), do: "Show Table"
  defp page_title(:edit), do: "Edit Table"
  defp page_title(:join), do: "Join Tables"

  def is_not_join!(%{"id" => id, "user_key" => user_key}) do
    !Planning.find_user(%{"id" => id, "user_key" => user_key})
  end

  @impl true
  def terminate(reason, socket) do
    case reason do
      {:shutdown, :closed} ->
        Planning.delete_user(%{"id" => socket.assigns.table.id, "user_key" => socket.assigns.user_key})
    end
    reason
  end
end
