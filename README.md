# GraphqlExample

## Step by step tutorial on setting up graphql in Phoenix


Set Up a new Phoenix app with

    mix phx.new graphql_example
    cd graphql_example

Then create the database with

    mix ecto.create

We want to be able to create users and login so we can setup authenthication functionality.

    mix phx.gen.context Authentication User users name:string email:string password_hash:string

Update the migration file so we will only allow unique emails


    create table(:users) do
      add :name, :string
      add :email, :string, null: false
      add :password_hash, :string, null: false

      timestamps()
    end

    create index(:users, :email, unique: true)

And then run the migration.

    mix ecto.migrate

Since we want to encrypt the password when a user signs up, we need to add a library for that. Open `mix.exs` and add

    ...
    {:bcrypt_elixir, "~> 2.0"}

And run

    mix deps.get

The login functionality lives both in the User-module and the Authentication module.
Open `lib/graphql_example/authentication/user.ex` and change to

	defmodule GraphqlExample.Authentication.User do
	  use Ecto.Schema
	  import Ecto.Changeset

	  schema "users" do
	    field :email, :string
	    field :name, :string
	    field :password, :string, virtual: true
	    field :password_confirmation, :string, virtual: true
	    field :password_hash, :string

	    timestamps()
	  end

	  @doc false
	  def changeset(user, attrs) do
	    user
	    |> cast(attrs, [:name, :email, :password, :password_confirmation])
	    |> validate_required([:email, :password, :password_confirmation])
	    |> validate_format(:email, ~r/@/)
	    |> unique_constraint(:email)
	    |> validate_length(:password, min: 6, max: 100)
	    |> validate_confirmation(:password)
	    |> put_pass_hash()
	  end

	  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
	    change(changeset, Bcrypt.add_hash(password))
	  end
	  defp put_pass_hash(changeset), do: changeset
	end

And then add the actual password check in `lib/graphql_example/authentication.ex`

	@doc """
	Tries to authenticate the user via email and password.

	## Examples
	      iex> authenticate_user("some@email.com", "secret")
	      {:ok, %User{}}

	      iex> authenticate_user("some@email.com", "wrong")
	      {:error, "Error message"}
	"""
	def authenticate_user(email, password) do
	  Repo.get_by(User, email: email)
	  |> check_password(password)
	end

	defp check_password(user, password) do
	  case Bcrypt.check_pass(user, password) do
	    {:ok, user} -> {:ok, user}
	    _ -> {:error, "Incorrect email or password"}
       end
    end

When everything is saved, you shouls be able to run the tests and get them passing.

	mix test

### Generate resourses

We want our example app to be able to serve _Things_ and those _Things_ can have many _Features_. Also, a _Thing_ belongs to a _User_.

Generate our new resurces with the commands

```
mix phx.gen.context Things Thing things name:string user_id:references:users

mix phx.gen.context Things Feature features name:string thing_id:references:things
```

This generated two migrations and some files for us. Run the migrations by:

    mix ecto.migrate

Then open `lib/graphql_example/authentication/user.ex` and add the association to `:things` inside the schema block.

    ...
    field :password_hash, :string
    has_many :things, GraphqlExample.Things.Thing

You need to add the associations in the `Thing` module as well. `lib/graphql_example/things.ex`

    belongs_to :user, GraphqlExample.Authentication.User
    has_many :features, GraphqlExample.Things.Feature

And last, to the same inside `Feature`. Edit `lib/graphql_example/things/feature.ex`

    belongs_to :thing, GraphqlExample.Things.Thing

With all the associations setup, next step is to edit the context files so you need to pass in a `user` everytime you query for a thing. The logic will be that a user needs to register and authenticate to create or see it own _things_.

I won't show all methods but they will be in the commited code and it will look like this.

    def list_things(user) do
      Repo.all(from t in Thing, where: t.user_id == ^user.id, preload: [:features])
    end

    def get_thing!(user, id), do: Repo.get_by!(Thing, id: id, user_id: user.id)

_Features_ will get the same treatment, and requires a _thing_

    def list_features(thing) do
      Repo.all(from f in Feature,  where: f.thing_id == ^thing.id)
    end

    def get_feature!(thing, id), do: Repo.get_by!(Feature, id: id, thing_id: thing.id)

The rest of the changes is displayed [here](https://github.com/andreaseriksson/graphql_example/commit/803c121ed48f8daa7f2c8bba2b48ee0c3aa5834e#diff-a97223c0fd238b8ca135f17426766ac1R1)

You can also see how I setup the tests [here](https://github.com/andreaseriksson/graphql_example/commit/803c121ed48f8daa7f2c8bba2b48ee0c3aa5834e#diff-95ea6c628d4e03e68184ebadb5742274R1)

**Note**, I moved all fixtures to its own [file](https://github.com/andreaseriksson/graphql_example/commit/803c121ed48f8daa7f2c8bba2b48ee0c3aa5834e#diff-7fac3d824e94d677797510a1fe642f0aR1) for conveniense since I dont like to have them spread or duplicated in several files. Especially since the user fixture will be used in several places.


### Setup Absinthe and Guardian

Now we have finally come to the part where we will setup GraphQl. The first part will be user registration and signing in.

Open `mix.exs` and add

    {:absinthe, "~> 1.4.0"},
    {:absinthe_plug, "~> 1.4"},
    {:poison, "~> 3.0"},
    {:guardian, "~> 1.0"}

And then run

    mix deps.get

Lets begin with setting up the authentication logic with Guardian. Start with generating a secret key and copy it

	mix phx.gen.secret

Open `config/config.exs` and add

	config :graphql_example, GraphqlExample.Guardian,
	  issuer: "GraphqlExample",
	  secret_key: "MY_GENERATED_SECRET",
	  ttl: {30, :days}

Create a _Guardian_ file in `lib/guardian.ex`

	defmodule GraphqlExample.Guardian do
	  use Guardian, otp_app: :graphql_example

	  alias GraphqlExample.Authentication

	  def subject_for_token(resource, _claims) do
	    sub = to_string(resource.id)
	    {:ok, sub}
	  end

	  def resource_from_claims(claims) do
	    id = claims["sub"]
	    resource = Authentication.get_user!(id)
	    {:ok,  resource}
	  end
	end

Next step is to set up GraphQL and we want the GraphQL interface to live in its own folder in the web directory. Create the folder `lib/graphql_example_web/graphql/` and inside that folder create the file `lib/graphql_example_web/graphql/schema.ex`

That file will be the start point for the GraphQL interface. And speaking of that, we need to add a route to it. Update the `lib/graphql_example_web/router.ex`

    pipeline :api do
      plug :accepts, ["json"]
      plug GraphqlExampleWeb.Context
    end

    scope "/api" do
      pipe_through :api

      forward "/graphiql", Absinthe.Plug.GraphiQL, schema: GraphqlExampleWeb.Schema
      forward "/", Absinthe.Plug, schema: GraphqlExampleWeb.Schema
    end

We also need to create the custom plug `GraphqlExampleWeb.Context` that we will use for user authentication when quering the GraphQL endpoint. `lib/graphql_example_web/plugs/context.ex`

	defmodule GraphqlExampleWeb.Context do
	  @behaviour Plug

	  import Plug.Conn

	  def init(opts), do: opts

	  def call(conn, _) do
	    case build_context(conn) do
	      {:ok, context} ->
	        put_private(conn, :absinthe, %{context: context})

	      _ ->
	        conn
	    end
	  end

	  defp build_context(conn) do
	    with ["" <> token] <- get_req_header(conn, "authorization"),
	         {:ok, user, _claims} <- GraphqlExample.Guardian.resource_from_token(token) do
	      {:ok, %{current_user: user}}
	    end
	  end
	end

When that is done, we will defining and setting up the schema file. `lib/graphql_example_web/graphql/schema.ex` and that file will define all queries and mutations.

	defmodule GraphqlExampleWeb.Schema do
	  use Absinthe.Schema

	  alias GraphqlExampleWeb.Schema

	  import_types(Absinthe.Type.Custom)
	  import_types(Schema.UserTypes)
	  import_types(Schema.ThingTypes)

	  query do
	    import_fields(:get_things)
	    import_fields(:get_thing)
	  end

	  mutation do
	    import_fields(:login_mutation)
	    import_fields(:create_user_mutation)

	    import_fields(:create_thing)
	    import_fields(:update_thing)
	    import_fields(:delete_thing)
	  end
	end

This file alone doesnt specify how an instance of a user will look, what fields to expose. That happens in the _Type_ file. Create `lib/graphql_example_web/graphql/schema/user_types.ex`

	defmodule GraphqlExampleWeb.Schema.UserTypes do
	  use Absinthe.Schema.Notation

	  alias GraphqlExampleWeb.Resolvers

	  @desc "A user"
	  object :user do
	    field :email, :string
	    field :id, :id
	  end

	  object :create_user_mutation do
	    @desc """
	    create user
	    """

	    @desc "Create a user"
	    field :create_user, :user do
	      arg(:email, non_null(:string))
	      arg(:password, non_null(:string))
	      arg(:password_confirmation, non_null(:string))

	      resolve(&Resolvers.Authentication.create_user/3)
	    end
	  end

	  object :login_mutation do
	    @desc """
	    login with the params
	    """

	    field :create_session, :session do
	      arg(:email, non_null(:string))
	      arg(:password, non_null(:string))
	      resolve(&Resolvers.Authentication.login/2)
	    end
	  end

	  @desc "session value"
	  object :session do
	    field(:token, :string)
	    field(:user, :user)
	  end
	end

As you can see, this file referensers the _resolvers_ so lets create that as well.
`lib/graphql_example_web/graphql/resolvers/authentication.ex`

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


This part should be enough for registering a new user and creating a new user _session_ with a jason web token (jwt) that will be used for the _things_ CRUD. Lets start with that.

First make a function in the `Things` module. Open `lib/graphql_example/things.ex` and add

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

Then add the types and resolvers for things. Basically what we want us the normal CRUD operations. Add the file `lib/graphql_example_web/graphql/schema/thing_types.ex` with

	defmodule GraphqlExampleWeb.Schema.ThingTypes do
	  use Absinthe.Schema.Notation

	  alias GraphqlExampleWeb.Resolvers

	  @desc "A thing"
	  object :thing do
	    field :name, :string
	    field :id, :id
	  end

	  object :get_things do
	    @desc """
	    Get a list of things
	    """

	    field :things, list_of(:thing) do
	      resolve(&Resolvers.Things.list_things/2)
	    end
	  end

	  object :get_thing do
	    @desc """
	    Get a specific thing
	    """

	    field :thing, :thing do
	      arg(:id, non_null(:id))

	      resolve(&Resolvers.Things.get_thing/2)
	    end
	  end

	  object :create_thing do
	    @desc """
	    Create a thing
	    """

	    @desc "Create a thing"
	    field :create_thing, :thing do
	      arg(:name, :string)

	      resolve(&Resolvers.Things.create_thing/2)
	    end
	  end

	  object :update_thing do
	    @desc """
	    Update a thing
	    """

	    @desc "Update a thing"
	    field :update_thing, :thing do
	      arg(:id, non_null(:id))
	      arg(:name, :string)

	      resolve(&Resolvers.Things.update_thing/2)
	    end
	  end

	  object :delete_thing do
	    @desc """
	    Delete a specific thing
	    """

	    field :delete_thing, :thing do
	      arg(:id, non_null(:id))

	      resolve(&Resolvers.Things.delete_thing/2)
	    end
	  end
	end

And last att the resolvers in the file `lib/graphql_example_web/graphql/resolvers/things.ex`

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


The source code also provides tests. The tests are basically modified controller tests that performs a simulated request to the graphql endpoint.

You can find them [here in this commit](https://github.com/andreaseriksson/graphql_example/commit/f0379fe85a627869617eaec0833429d0ba245536#diff-33fe6b3265a50dcfc224903e14e2dcb4R1)


To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

