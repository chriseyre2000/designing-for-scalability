defmodule Hlr do
  @moduledoc """

  This maps phone subscriber to processes using the :ets database

"""

  @subscriber2Pid :msisdn2pid
  @pid2subscriber :pid2msisdn


  def new() do
    :ets.new(@subscriber2Pid, [:public, :named_table])
    :ets.new(@pid2subscriber, [:public, :named_table])
    :ok
  end

  def attach(ms) do
    :ets.insert(@subscriber2Pid, {ms, self()})
    :ets.insert(@pid2subscriber, {self(), ms})
  end

  def detach() do
    case :ets.lookup(@pid2subscriber, self()) do
      [{pid, ms}] ->
        :ets.delete(@pid2subscriber, pid)
        :ets.delete(@subscriber2Pid, ms)
      [] -> :ok
    end
  end

  def lookup_id(ms) do
    case :ets.lookup(@subscriber2Pid, ms) do
      [] -> {:error, :invalid}
      [{ms, pid}] -> {:ok, pid}
    end
  end

  def lookup_ms(pid) do
    case :ets.lookup(@pid2subscriber, pid) do
      [] -> {:error, :invalid}
      [{pid,ms}] -> {:ok, ms}
    end
  end
end