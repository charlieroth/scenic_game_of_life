defmodule GameOfLife.Scene.TheGrid do
  use Scenic.Scene

  require Logger

  alias Scenic.Graph
  alias GameOfLife.Cell

  import Scenic.Primitives

  def init(_, opts) do
    viewport = opts[:viewport]

    l = 30
    w = 30
    cells = generate_cells(l, w)
    graph = render_grid(cells)

    state = %{
      viewport: viewport,
      graph: graph,
      epoch: 0,
      cells: cells
    }

    :timer.send_interval(200, {:evolve, l, w})
    :timer.send_interval(2000, {:glider})

    {:ok, state, push: graph}
  end

  def handle_info({:evolve, l, w}, state) do
    new_epoch = state.epoch + 1
    new_cells = evolution(l, w, state.cells)
    new_graph = render_grid(new_cells)
    new_state = %{state | cells: new_cells, epoch: new_epoch, graph: new_graph}
    {:noreply, new_state, push: new_graph}
  end

  def handle_info({:glider}, state) do
    new_cells = spawn_glider(state.cells)
    new_graph = render_grid(new_cells)
    new_state = %{state | cells: new_cells, graph: new_graph}
    {:noreply, new_state, push: new_graph}
  end

  def render_grid(cells) do
    graph = Graph.build(theme: :light)

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

  def evolution(l, w, cells) do
    Enum.reduce(cells, %{}, fn cell, acc ->
      {pos, new_cell} = evolve_cell(l, w, cells, cell)
      Map.put(acc, pos, new_cell)
    end)
  end

  def evolve_cell(l, w, cells, {pos, c} = cell) do
    neighbors_alive =
      cell
      |> get_neighbor_positions()
      |> get_num_neighbors_alive(cells, l, w)

    case {c.alive, neighbors_alive} do
      # 1. Any live cell with fewer than two live neighbors dies
      {true, na} when na < 2 -> {pos, %Cell{c | alive: false}}
      # 2. Any live cell with two or three live neighbors lives
      {true, na} when na == 2 -> cell
      {true, na} when na == 3 -> cell
      # 3. Any live cell with more than three live neighbors dies
      {true, na} when na > 3 -> {pos, %Cell{c | alive: false}}
      # 4. Any dead cell with exactly three live neighbors becomes a live cell
      {false, na} when na === 3 -> {pos, %Cell{c | alive: true}}
      _ -> cell
    end
  end

  def get_num_neighbors_alive(neighbor_positions, cells, l, w) do
    Enum.reduce(neighbor_positions, 0, fn {x, y} = neighbor_position, count ->
      # Ensure checking only in bounds neighbors
      case {x <= w - 1, x >= 0, y <= l - 1, y >= 0} do
        {true, true, true, true} ->
          cell = cells[neighbor_position]
          if cell.alive, do: count + 1, else: count

        _ ->
          count
      end
    end)
  end

  def get_neighbor_positions({{x, y} = _pos, _c} = _cell) do
    [
      # top-left
      {x - 1, y - 1},
      # top-center
      {x, y - 1},
      # top-right
      {x + 1, y - 1},
      # middle-left
      {x - 1, y},
      # middle-right
      {x + 1, y},
      # bottom-left
      {x - 1, y + 1},
      # bottom-center
      {x, y + 1},
      # bottom-right
      {x + 1, y + 1}
    ]
  end

  def generate_cells(l, w) do
    for x <- 0..w, y <- 0..l, into: %{} do
      {{x, y}, %Cell{alive: false, translation: generate_translation(x, y)}}
    end
    |> spawn_glider()
  end

  def spawn_blinker(cells) do
    Enum.reduce(cells, cells, fn {pos, c} = _cell, acc ->
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

  def spawn_glider(cells) do
    Enum.reduce(cells, cells, fn {pos, c} = _cell, acc ->
      case pos do
        {14, 14} ->
          Map.put(acc, pos, %Cell{c | alive: true})

        {16, 14} ->
          Map.put(acc, pos, %Cell{c | alive: true})

        {15, 15} ->
          Map.put(acc, pos, %Cell{c | alive: true})

        {16, 15} ->
          Map.put(acc, pos, %Cell{c | alive: true})

        {15, 16} ->
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
