defmodule GraphqlExampleWeb.Schema.CreateUserTest do
  use GraphqlExampleWeb.ConnCase, async: false

  defp get_response(conn, args) do
    conn
    |> post("/api", args)
  end

  @query """
    mutation ($email: String!, $password: String!, $passwordConfirmation: String!) {
      user: createUser(email: $email, password: $password, passwordConfirmation: $passwordConfirmation) {
        email
      }
    }
  """

  defp get_post_args(:correct) do
    %{
      query: @query,
      variables: %{
        "email" => "foo@example.com",
        "password" => "secret",
        "passwordConfirmation" => "secret"
      }
    }
  end

  test "correct: create user", %{conn: conn} do
    args = get_post_args(:correct)

    response =
      conn
      |> get_response(args)

    assert json_response(response, 200) == %{
             "data" => %{
               "user" => %{
                 "email" => "foo@example.com"
               }
             }
           }
  end
end
