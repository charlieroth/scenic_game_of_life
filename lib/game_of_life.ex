defmodule GameOfLife do
  @moduledoc """
  Root process of application
  """
  def start(_type, _args) do
    # load the viewport configuration from config
    main_viewport_config = Application.get_env(:game_of_life, :viewport)

    # start the application with the viewport
    children = [
      {Scenic, viewports: [main_viewport_config]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
