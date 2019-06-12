defmodule GraphqlExample.Things do
  @moduledoc """
  The Things context.
  """

  import Ecto.Query, warn: false
  alias GraphqlExample.Repo

  alias GraphqlExample.Things.Thing

  @doc """
  Returns the list of things.

  ## Examples

      iex> list_things(user)
      [%Thing{}, ...]

  """
  def list_things(user) do
    Repo.all(from t in Thing, where: t.user_id == ^user.id, preload: [:features])
  end

  @doc """
  Gets a single thing.

  Raises `Ecto.NoResultsError` if the Thing does not exist.

  ## Examples

      iex> get_thing!(user, 123)
      %Thing{}

      iex> get_thing!(user, 456)
      ** (Ecto.NoResultsError)

  """
  def get_thing!(user, id), do: Repo.get_by!(Thing, id: id, user_id: user.id)

  @doc """
  Gets a single thing.

  Returns nil if the Thing does not exist.

  ## Examples

      iex> get_thing(user, 123)
      %Thing{}

      iex> get_thing(user, 456)
      ** nil

  """
  def get_thing(user, id), do: Repo.get_by(Thing, id: id, user_id: user.id)

  @doc """
  Creates a thing.

  ## Examples

      iex> create_thing(user, %{field: value})
      {:ok, %Thing{}}

      iex> create_thing(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_thing(user, attrs \\ %{}) do
    %Thing{}
    |> Thing.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Updates a thing.

  ## Examples

      iex> update_thing(thing, %{field: new_value})
      {:ok, %Thing{}}

      iex> update_thing(thing, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_thing(%Thing{} = thing, attrs) do
    thing
    |> Thing.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Thing.

  ## Examples

      iex> delete_thing(thing)
      {:ok, %Thing{}}

      iex> delete_thing(thing)
      {:error, %Ecto.Changeset{}}

  """
  def delete_thing(%Thing{} = thing) do
    Repo.delete(thing)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking thing changes.

  ## Examples

      iex> change_thing(thing)
      %Ecto.Changeset{source: %Thing{}}

  """
  def change_thing(%Thing{} = thing) do
    Thing.changeset(thing, %{})
  end

  alias GraphqlExample.Things.Feature

  @doc """
  Returns the list of features.

  ## Examples

      iex> list_features(thing)
      [%Feature{}, ...]

  """
  def list_features(thing) do
    Repo.all(from f in Feature,  where: f.thing_id == ^thing.id)
  end

  @doc """
  Gets a single feature.

  Raises `Ecto.NoResultsError` if the Feature does not exist.

  ## Examples

      iex> get_feature!(thing, 123)
      %Feature{}

      iex> get_feature!(thing, 456)
      ** (Ecto.NoResultsError)

  """
  def get_feature!(thing, id), do: Repo.get_by!(Feature, id: id, thing_id: thing.id)

  @doc """
  Creates a feature.

  ## Examples

      iex> create_feature(thing, %{field: value})
      {:ok, %Feature{}}

      iex> create_feature(thing, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_feature(thing, attrs \\ %{}) do
    %Feature{}
    |> Feature.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:thing, thing)
    |> Repo.insert()
  end

  @doc """
  Updates a feature.

  ## Examples

      iex> update_feature(feature, %{field: new_value})
      {:ok, %Feature{}}

      iex> update_feature(feature, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_feature(%Feature{} = feature, attrs) do
    feature
    |> Feature.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Feature.

  ## Examples

      iex> delete_feature(feature)
      {:ok, %Feature{}}

      iex> delete_feature(feature)
      {:error, %Ecto.Changeset{}}

  """
  def delete_feature(%Feature{} = feature) do
    Repo.delete(feature)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking feature changes.

  ## Examples

      iex> change_feature(feature)
      %Ecto.Changeset{source: %Feature{}}

  """
  def change_feature(%Feature{} = feature) do
    Feature.changeset(feature, %{})
  end
end
