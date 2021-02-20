defmodule GameOfLife.Scene.TheGrid do
  use Scenic.Scene
  require Logger
  alias Scenic.Graph
  # alias Scenic.ViewPort
  import Scenic.Primitives
  # import Scenic.Components

  def init(_, _opts) do
    graph =
      Graph.build(font: :roboto, font_size: 24)
      |> text("The Grid", text_align: :center, translate: {300, 300})

    {:ok, graph, push: graph}
  end

  def filter_event({:click, :start_btn_id}, _from, state) do
    IO.puts("Start button clicked")
    {:noreply, state}
  end
end
