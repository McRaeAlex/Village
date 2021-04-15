defmodule VillageWeb.PostComponent do
  use VillageWeb, :live_component

  alias Village.Feed

  @impl true
  def mount(socket) do
    {:ok, socket |> assign(editing: false)}
  end

  # @impl true
  # def preload(list_of_assigns) do
  #   list_of_post_ids = Enum.map(list_of_assigns, & &1.post_id)

  #   posts = from(f in Feed.Post, where: f.id in ^list_of_post_ids, select: {u.id, u})
  #     |> Repo.all()
  #     |> Map.new()

  #   Enum.map(list_of_assigns, fn assigns ->
  #     Map.put(assigns, :post, post[assigns.post_id])
  #   end)
  # end

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign(changeset: Feed.change_post(assigns[:post]))}
  end

  @impl true
  def handle_event("delete", %{"post_id" => post_id}, socket) do
    user = socket.assigns[:current_user]
    post = socket.assigns[:post]

    with :ok <- Bodyguard.permit(Feed, :delete, user, post),
         {:ok, post} <- Feed.delete_post(post) do
      socket =
        socket
        |> put_flash(:notice, "Post deleted successfully.")

      send(self(), {:post_deleted, post})
      {:noreply, socket}
    else
      {:error, :unauthorized} ->
        {:noreply, socket |> put_flash(:error, "Your not authorized to delete that post!")}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply, socket |> put_flash(:error, "Failed to delete post. Already deleted")}

      {:error, _reason} ->
        {:noreply, socket |> put_flash(:error, "Failed to delete post.")}
    end
  end

  @impl true
  def handle_event("edit", %{"post" => updated_post} = params, socket) do
    user = socket.assigns[:current_user]
    post = socket.assigns[:post]

    with :ok <- Bodyguard.permit(Feed, :edit, user, post),
         {:ok, post} <- Feed.update_post(post, updated_post) do
      socket =
        socket
        |> assign(post: post)
        |> update(:editing, fn editing -> !editing end)
        |> put_flash(:notice, "Post updated successfully.")

      {:noreply, socket}
    else
      {:error, :unauthorized} ->
        {:noreply, socket |> put_flash(:error, "Your not authorized to edit that post!")}

      {:error, _reason} ->
        {:noreply, socket |> put_flash(:error, "Failed to edit post.")}
    end
  end

  @impl true
  def handle_event("toggle_edit", _, socket) do
    {:noreply, socket |> update(:editing, fn editing -> !editing end)}
  end

  defp controls(assigns) do
    ~L"""
    <span class="origin-top-right absolute right-2 top-1 cursor-pointer" x-on:click="open = true">x</span>
    <div class="origin-top-right absolute right-0 top-0 mt-2 w-48 rounded-md shadow-lg"
        x-show.transition="open"
        x-on:click.away="open = false">
        <div class="py-1 rounded-md bg-white shadow-xs">
            <a x-on:click="open = false" phx-target="<%= @myself %>" phx-click="toggle_edit" class="block px-4 py-2 text-sm leading-5 hover:bg-gray-100">
                Edit
            </a>
            <a phx-target="<%= @myself %>" phx-click="delete" phx-value-post_id="<%= @id %>" class="block px-4 py-2 text-sm leading-5 hover:bg-gray-100">
                Delete
            </a>
        </div>
    </div>
    """
  end

  defp edit(assigns) do
    ~L"""
    <div>
      <%= f = form_for @changeset, "#", [phx_target: @myself, phx_submit: :edit] %>
        <%= textarea f, :content, class: "rounded resize-none max-w-full w-full outline" %><br>
        <%= submit "Update!", class: "bg-gray-200 p1 shadow-sm rounded" %>
        <button type="button" phx-target="<%= @myself %>" phx-click="toggle_edit" class="bg-gray-100"> Cancel </button>
      </form>
    </div>
    """
  end

  @impl true
  def render(assigns) do
    ~L"""
    <% 
      # Variables
      deleted = @post.__meta__.state == :deleted
      show_controls = @current_user.id == @post.author_id
    %>
    <div class="bg-gray-50 p-4 w-96 shadow-lg rounded relative <%= if deleted do %>hidden<% end %>"
        x-data="{open: false}"
        id="post-<%= @id %>"
    >
      <div id="post-live-flash-notice-<%= @post.id %>" phx-hook="Toaster"><%= live_flash(@flash, :notice) %></div>
      <h2>
          <%= @post.author.email%>
      </h2>
      <%= if show_controls do %>
            <%= controls(assigns) %>
      <% end %>
      <%= if @editing do %>
        <%# Show the edit form %>
        <%= edit(assigns) %>
      <% else %>
        <%# Show the controls to modify and delete posts %>
        
        <p>
            <%= @post.content %>
        </p>
        <div>
            <!-- New Comment -->
            <!-- Comments -->
        </div>
      <% end %>
    </div>
    """
  end
end
