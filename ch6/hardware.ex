defmodule Hardware do
  @moduledoc false

  def display(str, arg \\ []), do: IO.puts "Display #{str}"
  def return_change(payment), do: IO.puts "Machine:Returned #{payment} in change"
  def drop_cup, do: IO.puts "Machine:Dropped cup"
  def prepare(type), do: IO.puts "Machine:preparing #{inspect type}"
  def reboot, do: IO.puts "Machine:Rebooted hardware"
end