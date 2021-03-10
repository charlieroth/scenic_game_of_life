defmodule GameOfLife.Cell do
  @moduledoc """
  Represents a cell in the grid of life
  """
  defstruct alive: false, translation: {0, 0}
end
