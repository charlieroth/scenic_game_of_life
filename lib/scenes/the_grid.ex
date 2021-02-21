defmodule GameOfLife.Scene.TheGrid do
  use Scenic.Scene
  require Logger
  alias Scenic.Graph
  alias GameOfLife.Cell
  # alias Scenic.ViewPort
  import Scenic.Primitives
  # import Scenic.Components

  def init(_, opts) do
    viewport = opts[:viewport]

    cells = generate_cells(30, 30)

    graph =
      Graph.build(font: :roboto, font_size: 24, theme: :light)
      |> render_grid(cells)

    world = %{
      viewport: viewport,
      graph: graph,
      state: %{
        num_alive: 3,
        epoch: 0,
        cells: {}
      }
    }

    {:ok, world, push: graph}
  end

  def filter_event({:click, :start_btn_id}, _from, world) do
    IO.puts("Start button clicked")
    {:noreply, world}
  end

  def generate_cells(l, w) do
    for x <- 0..w, y <- 0..l, into: %{} do
      {{x, y}, %Cell{alive: false, translation: generate_translation(x, y)}}
    end
    |> insert_blinker()
  end

  def render_grid(graph, cells) do
    Enum.reduce(cells, graph, fn {_pos, cell}, acc ->
      if cell.alive do
        acc
        |> rectangle({20, 20}, fill: :black, translate: cell.translation)
      else
        acc
        |> rectangle({20, 20}, fill: :white, translate: cell.translation)
      end
    end)
  end

  def insert_blinker(cells) do
    Enum.reduce(cells, %{}, fn {pos, c} = _cell, acc ->
      case pos do
        {14, 15} ->
          Map.put(acc, pos, %Cell{c | alive: true})

        {15, 15} ->
          Map.put(acc, pos, %Cell{c | alive: true})

        {16, 15} ->
          Map.put(acc, pos, %Cell{c | alive: true})

        _ ->
          acc
      end
    end)
  end

  def generate_translation(x, y) do
    {x * 20, y * 20}
  end
end
