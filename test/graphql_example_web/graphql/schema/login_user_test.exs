defmodule GraphqlExampleWeb.Schema.LoginUserTest do
  use GraphqlExampleWeb.ConnCase, async: false
  alias GraphqlExample.Authentication

  defp get_response(conn, args) do
    conn
    |> post("/api", args)
  end

  @query """
    mutation ($email: String!, $password: String!) {
      session: createSession(email: $email, password: $password) {
        token
      }
    }
  """

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{})
      |> Authentication.create_user()

    user
  end

  defp get_post_args(:correct) do
    %{
      query: @query,
      variables: %{
        "email" => "foo@example.com",
        "password" => "secret"
      }
    }
  end

  defp get_post_args(:incorrect) do
    %{
      query: @query,
      variables: %{
        "email" => "foo@example.com",
        "password" => "wrong"
      }
    }
  end

  test "create user mutation with correct credentials", %{conn: conn} do
    user_fixture(email: "foo@example.com", password: "secret", password_confirmation: "secret")

    args = get_post_args(:correct)

    response =
      conn
      |> get_response(args)

    assert %{
             "data" => %{
               "session" => %{
                 "token" => "" <> _
               }
             }
           } = json_response(response, 200)
  end

  test "create user mutation with incorrect credentials", %{conn: conn} do
    user_fixture(email: "foo@example.com", password: "secret", password_confirmation: "secret")

    args = get_post_args(:incorrect)

    response =
      conn
      |> get_response(args)

    assert %{
             "data" => %{
               "session" => nil
             },
             "errors" => [
               %{
                 "message" => "Incorrect email or password"
               }
             ]
           } = json_response(response, 200)
  end
end
