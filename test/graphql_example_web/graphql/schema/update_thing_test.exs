defmodule GraphqlExampleWeb.Schema.UpdateThingTest do
  use GraphqlExampleWeb.ConnCase, async: false
  import GraphqlExample.GraphqlTestHelpers

  defp get_response(conn, args) do
    conn
    |> post("/api", args)
  end

  @query """
    mutation (
      $id: ID!,
      $name: String,
    ) {
      thing: updateThing(
        id: $id,
        name: $name,
      ) {
        id
        name
      }
    }
  """

  @valid_attrs %{
    name: "some name"
  }

  defp get_post_args(args) do
    %{
      query: @query,
      variables: %{
        "id" => "#{args[:id]}",
        "name" => args[:name]
      }
    }
  end

  describe "when not logged in" do
    setup [:user_with_invalid_jwt, :with_thing]

    test "update thing with invalid credentials", %{conn: conn, thing: thing} do
      attrs = Map.put(@valid_attrs, :id, thing.id)
      args = get_post_args(attrs)

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
    setup [:user_with_valid_jwt, :with_thing]

    test "update thing with valid attributes", %{conn: conn, jwt: jwt, thing: thing} do
      attrs = Map.put(@valid_attrs, :id, thing.id)
      args = get_post_args(attrs)

      response =
        conn
        |> put_req_header("authorization", jwt)
        |> get_response(args)

      assert %{
               "data" => %{
                 "thing" => %{
                   "name" => "some name",
                   "id" => thing_id
                 }
               }
             } = json_response(response, 200)

      assert thing_id == "#{thing.id}"
    end

    test "update thing when id is wrong", %{conn: conn, jwt: jwt} do
      attrs = Map.put(@valid_attrs, :id, 0)
      args = get_post_args(attrs)

      response =
        conn
        |> put_req_header("authorization", jwt)
        |> get_response(args)

      assert %{
               "data" => %{
                 "thing" => nil
               }
             } = json_response(response, 200)
    end
  end
end
