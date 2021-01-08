defmodule VillageWeb.PostComponent do
    use VillageWeb, :live_component

    def mount(_params, _session, socket) do
        {:ok, socket}
    end

    def render(assigns) do
        ~L"""
        <div class="bg-red-400 p-4 md:w-96 shadow-md rounded">
            <h2>
                <%= @name %>
            </h2>
            <p>
                <%= @content %>
            </p>
            <div>
                <!-- New Comment -->
                <!-- Comments -->
            </div>
        </div>
        """
    end
end