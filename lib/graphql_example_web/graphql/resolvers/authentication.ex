defmodule GraphqlExampleWeb.Resolvers.Authentication do
  alias GraphqlExample.Authentication

  def create_user(_parent, args, _context) do
    Authentication.create_user(args)
  end

  def login(%{email: email, password: password}, _info) do
    with {:ok, user} <- Authentication.authenticate_user(email, password),
         {:ok, jwt, _} <- GraphqlExample.Guardian.encode_and_sign(user) do
      {:ok, %{token: jwt}}
    end
  end
end
