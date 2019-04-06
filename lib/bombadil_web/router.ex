defmodule BombadilWeb.Router do
  use BombadilWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BombadilWeb do
    pipe_through :api
  end

  scope "/" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: BombadilWeb.Schema
    forward "/", Absinthe.Plug, schema: BombadilWeb.Schema
  end
end
