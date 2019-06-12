defmodule GraphqlExample.GraphqlTestHelpers do
  import GraphqlExample.Fixtures

  def user_with_valid_jwt(%{conn: conn}) do
    user = user_fixture()

    {:ok, jwt, _full_claims} = GraphqlExample.Guardian.encode_and_sign(user)
    {:ok, conn: conn, jwt: jwt, user: user}
  end

  def user_with_invalid_jwt(%{conn: conn}) do
    user = user_fixture()

    {:ok, conn: conn, jwt: nil, user: user}
  end

  def with_thing(%{user: user}) do
    thing = thing_fixture(user)
    [thing: thing]
  end
end
