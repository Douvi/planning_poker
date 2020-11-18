
defmodule PlanningPokerWeb.ModalComponent do
  use PlanningPokerWeb, :live_component

  @impl true
  def render(assigns) do
    case assigns.id do
      :modal_locked ->
        ~L"""
        <div id="<%= @id %>" class="phx-modal"
          phx-key="escape"
          phx-target="#<%= @id %>"
          phx-page-loading>

          <div class="phx-modal-content">
            <%= live_patch raw("&times;"), to: @return_to, class: "phx-modal-close" %>
            <%= live_component @socket, @component, @opts %>
          </div>
        </div>
        """
      _ ->
        ~L"""
        <div id="<%= @id %>" class="phx-modal"
          phx-capture-click="close"
          phx-window-keydown="close"
          phx-key="escape"
          phx-target="#<%= @id %>"
          phx-page-loading>

          <div class="phx-modal-content">
            <%= live_patch raw("&times;"), to: @return_to, class: "phx-modal-close" %>
            <%= live_component @socket, @component, @opts %>
          </div>
        </div>
        """
    end


  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
