# Pleroma: A lightweight social networking server
# Copyright © 2017-2022 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.ApiSpec.Admin.WebhookOperation do
  alias OpenApiSpex.Operation
  alias OpenApiSpex.Schema

  import Pleroma.Web.ApiSpec.Helpers

  def open_api_operation(action) do
    operation = String.to_existing_atom("#{action}_operation")
    apply(__MODULE__, operation, [])
  end

  def index_operation do
    %Operation{
      tags: ["Webhooks"],
      summary: "Retrieve a list of webhooks",
      operationId: "AdminAPI.WebhookController.index",
      security: [%{"oAuth" => ["admin:show"]}],
      responses: %{
        200 =>
          Operation.response("Array of webhooks", "application/json", %Schema{
            type: :array,
            items: webhook()
          })
      }
    }
  end

  def show_operation do
    %Operation{
      tags: ["Webhooks"],
      summary: "Retrieve a webhook",
      operationId: "AdminAPI.WebhookController.show",
      security: [%{"oAuth" => ["admin:show"]}],
      parameters: [id_param()],
      responses: %{
        200 => Operation.response("Webhook", "application/json", webhook())
      }
    }
  end

  def create_operation do
    %Operation{
      tags: ["Webhooks"],
      summary: "Create a webhook",
      operationId: "AdminAPI.WebhookController.create",
      security: [%{"oAuth" => ["admin:write"]}],
      requestBody:
        request_body(
          "Parameters",
          %Schema{
            description: "POST body for creating a webhook",
            type: :object,
            properties: %{
              url: %Schema{type: :string, format: :uri, required: true},
              events: event_type(true),
              enabled: %Schema{type: :boolean}
            }
          }
        ),
      responses: %{
        200 => Operation.response("Webhook", "application/json", webhook())
      }
    }
  end

  def update_operation do
    %Operation{
      tags: ["Webhooks"],
      summary: "Update a webhook",
      operationId: "AdminAPI.WebhookController.update",
      security: [%{"oAuth" => ["admin:write"]}],
      parameters: [id_param()],
      requestBody:
        request_body(
          "Parameters",
          %Schema{
            description: "POST body for updating a webhook",
            type: :object,
            properties: %{
              url: %Schema{type: :string, format: :uri},
              events: event_type(),
              enabled: %Schema{type: :boolean}
            }
          }
        ),
      responses: %{
        200 => Operation.response("Webhook", "application/json", webhook())
      }
    }
  end

  def delete_operation do
    %Operation{
      tags: ["Webhooks"],
      summary: "Delete a webhook",
      operationId: "AdminAPI.WebhookController.delete",
      security: [%{"oAuth" => ["admin:write"]}],
      parameters: [id_param()],
      responses: %{
        200 => Operation.response("Webhook", "application/json", webhook())
      }
    }
  end

  def enable_operation do
    %Operation{
      tags: ["Webhooks"],
      summary: "Enable a webhook",
      operationId: "AdminAPI.WebhookController.enable",
      security: [%{"oAuth" => ["admin:write"]}],
      parameters: [id_param()],
      responses: %{
        200 => Operation.response("Webhook", "application/json", webhook())
      }
    }
  end

  def disable_operation do
    %Operation{
      tags: ["Webhooks"],
      summary: "Disable a webhook",
      operationId: "AdminAPI.WebhookController.disable",
      security: [%{"oAuth" => ["admin:write"]}],
      parameters: [id_param()],
      responses: %{
        200 => Operation.response("Webhook", "application/json", webhook())
      }
    }
  end

  def rotate_secret_operation do
    %Operation{
      tags: ["Webhooks"],
      summary: "Rotate webhook signing secret",
      operationId: "AdminAPI.WebhookController.rotate_secret",
      security: [%{"oAuth" => ["admin:write"]}],
      parameters: [id_param()],
      responses: %{
        200 => Operation.response("Webhook", "application/json", webhook())
      }
    }
  end

  defp webhook do
    %Schema{
      title: "Webhook",
      description: "Schema for a webhook",
      type: :object,
      properties: %{
        id: %Schema{type: :string},
        url: %Schema{type: :string, format: :uri},
        events: event_type(),
        secret: %Schema{type: :string},
        enabled: %Schema{type: :boolean},
        created_at: %Schema{type: :string, format: :"date-time"},
        updated_at: %Schema{type: :string, format: :"date-time"}
      },
      example: %{
        "id" => "1",
        "url" => "https://example.com/webhook",
        "events" => ["report.created"],
        "secret" => "d3d8cf4bc11fd9c41fd34dcc38d282e451c8bd34",
        "enabled" => true,
        "created_at" => "2022-06-24T16:19:38.523Z",
        "updated_at" => "2022-06-24T16:19:38.523Z"
      }
    }
  end

  defp event_type(required \\ nil) do
    %Schema{
      type: :array,
      items: %Schema{
        title: "Event",
        description: "Event type",
        type: :string,
        enum: ["account.created", "report.created"],
        required: required
      }
    }
  end

  defp id_param do
    Operation.parameter(:id, :path, :string, "Webhook ID",
      example: "123",
      required: true
    )
  end
end
