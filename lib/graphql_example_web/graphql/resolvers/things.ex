defmodule GraphqlExampleWeb.Resolvers.Things do
  alias GraphqlExample.Things
  alias GraphqlExample.Things.Thing

  def list_things(_args, %{context: %{current_user: user}}) do
    {:ok, Things.list_things(user)}
  end

  def list_things(_args, _context), do: {:error, "Not Authorized"}

  def get_thing(%{id: id}, %{context: %{current_user: user}}) do
    {:ok, Things.get_thing(user, id)}
  end

  def get_thing(_args, _context), do: {:error, "Not Authorized"}

  def create_thing(args, %{context: %{current_user: user}}) do
    case Things.create_thing(user, args) do
      {:ok, %Thing{} = thing} -> {:ok, thing}
      {:error, changeset} -> {:error, inspect(changeset.errors)}
    end
  end

  def create_thing(_args, _context), do: {:error, "Not Authorized"}

  def update_thing(%{id: id} = params, %{context: %{current_user: user}}) do
    case Things.get_thing(user, id) do
      nil ->
        {:error, "Thing not found"}

      %Thing{} = thing ->
        case Things.update_thing(thing, params) do
          {:ok, %Thing{} = thing} -> {:ok, thing}
          {:error, changeset} -> {:error, inspect(changeset.errors)}
        end
    end
  end

  def update_thing(_args, _context), do: {:error, "Not Authorized"}

  def delete_thing(%{id: id}, %{context: %{current_user: user}}) do
    case Things.get_thing(user, id) do
      nil -> {:error, "Thing not found"}
      %Thing{} = thing -> Things.delete_thing(thing)
    end
  end

  def delete_thing(_args, _context), do: {:error, "Not Authorized"}
end
