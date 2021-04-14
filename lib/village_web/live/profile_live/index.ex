defmodule VillageWeb.ProfileLive.Index do
  use VillageWeb, :live_view

  alias Village.Accounts
  alias Village.Feed
  alias VillageWeb.PostComponent

  @impl true
  def mount(params, %{"current_user" => current_user}, socket) do
    if connected?(socket), do: Feed.subscribe()

    socket =
      socket
      |> assign(
        current_user: current_user,
        page: 1,
        per_page: 10,
        posts: [],
        update_action: :prepend
      )
      |> assign_user(params, current_user)
      |> load_posts()

    {:ok, socket, temporary_assigns: [posts: []]}
  end

  @impl true
  def handle_info({:post_created, post}, socket) do
    {:noreply,
     socket |> update(:posts, fn posts -> [post | posts] end) |> assign(:update_action, :prepend)}
  end

  @impl true
  def handle_info({:post_deleted, post}, socket) do
    {:noreply, socket |> update(:posts, fn posts -> [post | posts] end)}
  end

  defp assign_user(socket, params, current_user) do
    case get_user(params) do
      {:ok, user} ->
        assign(socket, :user, user)

      {:no_params} ->
        assign(socket, :user, current_user)

      {:error, :cannot_find_user} ->
        assign(socket, :user, current_user)
        |> put_flash(:notice, "No such user")
    end
  end

  defp get_user(%{"id" => id}) do
    try do
      {:ok, Village.Accounts.get_user!(id)}
    rescue
      e in Ecto.NoResultsError ->
        {:error, :cannot_find_user}
    end
  end

  defp get_user(_params) do
    {:no_params}
  end

  defp load_posts(socket) do
    user = socket.assigns.user
    page = socket.assigns.page
    per_page = socket.assigns.per_page

    assign(socket,
      posts: Feed.list_user_posts(user),
      update_action: :append
    )
  end
end
