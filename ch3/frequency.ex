defmodule Frequency do
  @moduledoc false

  def start do
    register __MODULE__, spawn(Frequency, :init, [])
  end

  def init do
    frequencies = {get_frequencies(), []}
    loop frequencies
  end

  def get_frequencies do
    [10, 11, 12, 13, 14, 15]
  end

end