defmodule GraphqlExampleWeb.Schema.CreateThingTest do
  use GraphqlExampleWeb.ConnCase, async: false
  import GraphqlExample.GraphqlTestHelpers

  defp get_response(conn, args) do
    conn
    |> post("/api", args)
  end

  @query """
    mutation (
      $name: String!,
    ) {
      thing: createThing(
        name: $name,
      ) {
        name
      }
    }
  """

  @valid_attrs %{
    name: "some name"
  }

  @invalid_attrs %{
    name: nil
  }

  defp get_post_args(args) do
    %{
      query: @query,
      variables: %{
        "name" => args[:name]
      }
    }
  end

  describe "when not logged in" do
    test "create thing with invalid credentials", %{conn: conn} do
      args = get_post_args(@valid_attrs)

      response =
        conn
        |> get_response(args)

      assert %{
               "data" => %{"thing" => nil},
               "errors" => [
                 %{
                   "message" => "Not Authorized"
                 }
               ]
             } = json_response(response, 200)
    end
  end

  describe "when logged in" do
    setup [:user_with_valid_jwt]

    test "create thing with valid attributes", %{conn: conn, jwt: jwt, user: user} do
      args = get_post_args(@valid_attrs)

      response =
        conn
        |> put_req_header("authorization", jwt)
        |> get_response(args)

      assert %{
               "data" => %{
                 "thing" => %{
                   "name" => "some name"
                 }
               }
             } = json_response(response, 200)

      assert [_] = GraphqlExample.Things.list_things(user)
    end

    test "create thing with invalid attributes", %{conn: conn, jwt: jwt, user: user} do
      args = get_post_args(@invalid_attrs)

      response =
        conn
        |> put_req_header("authorization", jwt)
        |> get_response(args)

      assert %{
               "errors" => [
                 %{
                   "locations" => [_],
                   "message" => "Variable \"name\": Expected non-null, found null."
                 }
               ]
             } = json_response(response, 200)

      assert [] = GraphqlExample.Things.list_things(user)
    end
  end
end
