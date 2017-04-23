defmodule Echo do
  @moduledoc false

  def go do
    pid = spawn Echo, :loop, []
    send pid, {self(), :hello}
    receive do
      {_pid, msg} -> :io.format("~w~n", [msg])
    end
    send pid, :stop
  end

  def loop do
    receive do
      {from, msg} ->
          send from, {self(), msg}
          loop()
      :stop ->
          :ok
    end
  end
end