defmodule Pleroma.TranslationTest do
  use Pleroma.Web.ConnCase

  alias Pleroma.Translation
  # use Oban.Testing, repo: Pleroma.Repo

  setup do: clear_config([Pleroma.Translation, :service], TranslationMock)

  test "it translates text" do
    assert {:ok,
            %{
              content: "txet emos",
              detected_source_language: _,
              provider: _
            }} = Translation.translate("some text", "en", "uk")
  end

  test "it stores translation result in cache" do
    Translation.translate("some text", "en", "uk")

    assert {:ok, result} =
             Cachex.get(
               :translations_cache,
               "en/uk/#{:crypto.hash(:sha256, "some text") |> Base.encode64()}"
             )

    assert result.content == "txet emos"
  end
end
