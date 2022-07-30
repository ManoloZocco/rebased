# Pleroma: A lightweight social networking server
# Copyright © 2017-2022 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.ThreadSubscription do
  use Ecto.Schema

  alias Pleroma.Repo
  alias Pleroma.ThreadSubscription
  alias Pleroma.User

  import Ecto.Changeset
  import Ecto.Query

  schema "thread_subscriptions" do
    belongs_to(:user, User, type: FlakeId.Ecto.CompatType)
    field(:context, :string)
  end

  def changeset(subscription, params \\ %{}) do
    subscription
    |> cast(params, [:user_id, :context])
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:user_id, name: :thread_subscriptions_user_id_context_index)
  end

  def query(user_id, context) do
    user_binary_id = User.binary_id(user_id)

    ThreadSubscription
    |> where(user_id: ^user_binary_id)
    |> where(context: ^context)
  end

  def subscribers_query(context) do
    ThreadSubscription
    |> join(:inner, [ts], u in assoc(ts, :user))
    |> where([ts], ts.context == ^context)
    |> select([ts, u], u.ap_id)
  end

  def subscriber_ap_ids(context, ap_ids \\ nil, opts \\ [])

  # Note: applies to fake activities (ActivityPub.Utils.get_notified_from_object/1 etc.)
  def subscriber_ap_ids(context, _ap_ids, _opts) when is_nil(context), do: []

  def subscriber_ap_ids(context, ap_ids, opts) do
    context
    |> subscribers_query()
    |> maybe_filter_on_ap_id(ap_ids)
    |> maybe_filter_local(opts)
    |> Repo.all()
  end

  defp maybe_filter_on_ap_id(query, ap_ids) when is_list(ap_ids) do
    where(query, [ts, u], u.ap_id in ^ap_ids)
  end

  defp maybe_filter_on_ap_id(query, _ap_ids), do: query

  defp maybe_filter_local(query, opts) do
    local = Keyword.get(opts, :local)
    if not is_nil(local) do
      where(query, [ts, u], u.local == ^local)
    else
      query
    end
  end

  def add_subscription(user_id, context) do
    %ThreadSubscription{}
    |> changeset(%{user_id: user_id, context: context})
    |> Repo.insert()
  end

  def remove_subscription(user_id, context) do
    query(user_id, context)
    |> Repo.delete_all()
  end

  def exists?(user_id, context) do
    query(user_id, context)
    |> Repo.exists?()
  end
end
