defmodule GraphqlExampleWeb.Router do
  use GraphqlExampleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug GraphqlExampleWeb.Context
  end

  scope "/api" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: GraphqlExampleWeb.Schema
    forward "/", Absinthe.Plug, schema: GraphqlExampleWeb.Schema
  end

  scope "/", GraphqlExampleWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", GraphqlExampleWeb do
  #   pipe_through :api
  # end
end
