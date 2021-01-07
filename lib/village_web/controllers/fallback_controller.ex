defmodule VillageWeb.FallbackController do
    use VillageWeb, :controller

    def call(conn, {:error, :unauthorized}) do
        conn
        |> put_status(:forbidden)
        |> put_view(VillageWeb.ErrorView)
        |> render(:"403")
    end
end