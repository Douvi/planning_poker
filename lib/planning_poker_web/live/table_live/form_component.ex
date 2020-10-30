require Logger

defmodule PlanningPokerWeb.TableLive.FormComponent do
  use PlanningPokerWeb, :live_component

  alias PlanningPoker.Planning


  @impl true
  def update(%{table: table} = assigns, socket) do
    changeset = Planning.change_table(table)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"table" => table_params}, socket) do
    changeset =
      socket.assigns.table
      |> Planning.change_table(table_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", param, socket) do
    save_table(socket, socket.assigns.action, param)
  end

  defp save_table(socket, :edit, %{"table" => table_params}) do
    case Planning.update_table(socket.assigns.table, table_params) do
      {:ok, _table} ->
        {:noreply,
         socket
         |> put_flash(:info, "Table updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_table(socket, :new, %{"table" => table_params}) do
    case Planning.create_table(table_params) do
      {:ok, _table} ->
        {:noreply,
         socket
         |> put_flash(:info, "Table created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp save_table(socket, :join, %{"table" => %{"user_name" => user_name}}) do
    case Planning.add_user(socket.assigns.table, %{"id" => socket.assigns.user_key, "user_name" => user_name}) do
      {:ok, table} ->
        {:noreply,
         socket
         |> put_flash(:info, "User added successfully")
         |> push_redirect(to: Routes.table_show_path(socket, :show, table))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
