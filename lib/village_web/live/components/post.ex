defmodule VillageWeb.PostComponent do
    use VillageWeb, :live_component

    def mount(socket) do
        {:ok, socket}
    end

    def controls(assigns) do
        ~L"""
        <span class="origin-top-right absolute right-2 top-1 cursor-pointer" x-on:click="open = true">x</span>
        <div class="origin-top-right absolute right-0 top-0 mt-2 w-48 rounded-md shadow-lg"
            x-show.transition="open"
            x-on:click.away="open = false">
            <div class="py-1 rounded-md bg-white shadow-xs">
                <a phx-click="edit" phx-value-post_id="<%= @id %>" class="block px-4 py-2 text-sm leading-5 hover:bg-gray-100">
                    Edit
                </a>
                <a phx-click="delete" phx-value-post_id="<%= @id %>" class="block px-4 py-2 text-sm leading-5 hover:bg-gray-100">
                    Delete
                </a>
            </div>
        </div>
        """
    end

    def render(assigns) do
        ~L"""
        <div class="bg-gray-50 p-4 w-96 shadow-lg rounded relative <%= if @deleted do %>hidden<% end %>"
            x-data="{open: false}"
            id="post-<%= @id %>"
        >
            <h2>
                <%= @name %>
            </h2>
            <%# Show the controls to modify and delete posts %>
            <%= if @show_controls do %>
                <%= controls(assigns) %>
            <% end %>
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