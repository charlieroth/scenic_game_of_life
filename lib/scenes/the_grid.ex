defmodule GameOfLife.Scene.TheGrid do
  use Scenic.Scene
  require Logger
  alias Scenic.Graph
  alias Scenic.ViewPort
  import Scenic.Primitives
  import Scenic.Components

  @note """
    This is a very simple starter application.

    If you want a more full-on example, please start from:

    mix scenic.new.example
  """

  @text_size 24

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, opts) do
    {:ok, %ViewPort.Status{size: {width, height}}} = ViewPort.info(opts[:viewport])

    graph =
      Graph.build(font: :roboto, font_size: @text_size)
      |> add_specs_to_graph([
        text_spec(@note, translate: {20, 120}),
        rect_spec({width, height})
      ])
      |> button("Start", translate: {20, 300})

    {:ok, graph, push: graph}
  end

  def handle_input(_event, _context, state) do
    # Logger.info("Received event: #{inspect(event)}")
    {:noreply, state}
  end
end
