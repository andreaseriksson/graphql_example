defmodule GraphqlExample.Things.Thing do
  use Ecto.Schema
  import Ecto.Changeset

  schema "things" do
    field :name, :string
    belongs_to :user, GraphqlExample.Authentication.User
    has_many :features, GraphqlExample.Things.Feature

    timestamps()
  end

  @doc false
  def changeset(thing, attrs) do
    thing
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
