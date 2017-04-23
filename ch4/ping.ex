defmodule Ping do
  @moduledoc false

  use GenServer

@timeout 5000

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, :undefined, @timeout}
  end

  def handle_call(:start, _from, state) do
    {:reply, :started, state, @timeout}
  end

  def handle_call(:pause, _from, state) do
    {:reply, :paused, state}
  end

  def handle_info(_timeout, state) do
    IO.puts "We timed out"
    {:noreply, state, @timeout}
  end
end