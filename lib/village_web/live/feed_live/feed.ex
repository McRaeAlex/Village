defmodule VillageWeb.FeedLive do
  use VillageWeb, :live_view

  alias Village.Feed
  alias Village.Feed.Post

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :posts, list_posts())}
  end

  def handle_event("new") do
  end

  defp list_posts() do
    Feed.list_posts()
  end
end
