require Logger

defmodule PlanningPokerWeb.TableLive.Show do
  use PlanningPokerWeb, :live_view

  alias PlanningPoker.Planning
  use Timex

  @impl true
  def mount(%{"id" => id}, session, socket) do
    if connected?(socket), do: Planning.subscribe(id)

    socket = case session do
      %{"_csrf_token" => key} -> socket |> assign(:user_key, key)
      _ -> socket |> redirect(to: Routes.table_index_path(socket, :index))
    end

    {:ok, socket |> update_model(Planning.get_table!(id))}
  end

  @impl true
  def handle_info({:table_updated, table}, socket) do
    {:noreply, socket |> update_model(table)}
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, update_model(socket, socket.assigns.table)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:timer, 0)
     |> assign(:table, Planning.get_table!(id))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:timer, 0)
     |> assign(:table, Planning.get_table!(id))
  end

  defp apply_action(socket, :join, %{"id" => id}) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:timer, 0)
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

  defp apply_event(socket, "start_countdown", %{"id" => id}) do
    Planning.start_countdown!(id)

    socket
    |> assign(:table, Planning.get_table!(id))
  end

  defp apply_event(socket, "stop_countdown", %{"id" => id}) do
    if socket.assigns[:tref] != nil do
      :timer.cancel(socket.assigns.tref)
    end

    Planning.stop_countdown!(id)

    socket
      |> assign(:tref, nil)
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
    case reason do
      {:shutdown, :closed} ->
        Planning.delete_user(%{"id" => socket.assigns.table.id, "user_key" => socket.assigns.user_key})
        reason
      _ -> reason
    end
  end

  defp update_model(socket, table) do
    cond do
      # We are in middle of a countdown
      table.countdown_ending != nil ->
        timer =
          DateTime.diff(table.countdown_ending, DateTime.utc_now, :second)
          |> max(0)

        cond do
          # Time over - we need to clean the value
          timer == 0 and table.show_vote == false ->
            if socket.assigns[:tref] != nil do
              :timer.cancel(socket.assigns.tref)
            end
            Planning.show_vote!(table.id)
            socket |> assign(:tref, nil) |> assign(:timer, timer) |> assign(:table, Planning.get_table!(table.id))

          # Time not over over, check interval been call
          timer != 0 and socket.assigns[:tref] == nil ->
            {:ok, tref} = :timer.send_interval(900, self(), :tick)
            socket |> assign(:tref, tref) |> assign(:timer, timer) |> assign(:table, table)

          # else case
          true ->
            socket |> assign(:timer, timer) |> assign(:table, table)

        end

      # else case
      true ->
        if socket.assigns[:tref] != nil do
          :timer.cancel(socket.assigns.tref)
        end

        socket |> assign(:timer, 0) |> assign(:tref, nil) |> assign(:table, Planning.get_table!(table.id))
    end
  end
end
