defmodule VillageWeb.FeedLive do
  use VillageWeb, :live_view

  alias Village.Feed
  alias Village.Feed.Post

  def mount(_params, %{"current_user" => current_user}, socket) do
    {:ok, assign(socket, 
        posts: list_posts(),
        changeset: Feed.change_post(%Post{}),
        current_user: current_user
      )
    }
  end

  def handle_event("new", %{"post" => new_post}, socket) do
    user = socket.assigns[:current_user]

    case Feed.create_post(user, new_post) do
      {:ok, post} ->
        # Add the user to the post because we don't need to load it from the 
        # database
        post = Map.put(post, :author, user)

        {:noreply, 
          socket
          |> put_flash(:info, "Post created!")
          |> update(:posts, fn posts -> [post | posts] end)
        }

      {:error, changeset} ->
        {:noreply, update(socket, :changeset, changeset)}
    end
  end

  defp list_posts() do
    Feed.list_posts()
  end
end
