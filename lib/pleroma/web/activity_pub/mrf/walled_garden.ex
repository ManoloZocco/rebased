defmodule Pleroma.Web.ActivityPub.MRF.WalledGarden do
  @moduledoc "Rejects messages from foreign instances, but lets others react"
  @behaviour Pleroma.Web.ActivityPub.MRF

  alias Pleroma.Config

  defp check_local(%{host: actor_host} = _actor_info, object) do
    cond do
      actor_host == Config.get([Pleroma.Web.Endpoint, :url, :host]) -> {:ok, object}
      true -> {:reject, "[WalledGarden] Foreign status"}
    end
  end

  defp check_local(_actor_info, object), do: {:ok, object}

  @impl true
  def filter(%{"type" => "Create", "actor" => actor} = object) do
    check_local(URI.parse(actor), object)
  end

  def filter(message), do: {:ok, message}

  @impl true
  def describe,
    do: {:ok, %{mrf_walled_garden: Config.get(:mrf_walled_garden)}}

  @impl true
  def config_description do
    %{
      key: :mrf_walled_garden,
      related_policy: "Pleroma.Web.ActivityPub.MRF.WalledGarden",
      label: "MRF Wallled Garden",
      description: "Creates a walled garden",
      children: []
    }
  end
end
