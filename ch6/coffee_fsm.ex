defmodule CoffeeFsm do
  @moduledoc false

  use GenServer

  def start_link() do
    :gen_fsm.start_link({:local,__MODULE__}, __MODULE__, [], [])
  end

  def init([]) do
    Hardware.reboot()
    Hardware.display("Make your selection", [])
    Process.flag(:trap_exit, true)
    {:ok, :selection, []}
  end

  def stop() do
    :gen_fsm.sync_send_all_state_event(__MODULE__, :stop)
  end

  def handle_sync_event(:stop, _from, _state, loopdata) do
    {:stop, :normal, loopdata}
  end

  def terminate(_reason, payment, {_type, _price, paid}) do
    Hardware.return_change(paid)
  end

  def terminate(_reason, _statenam, _loopdata) do
    :ok
  end

  def handle_event(a, b, c) do
    IO.puts "handle_event called with '#{inspect a}' '#{inspect b}' '#{inspect c}'"
    :gen_fsm.handle_event(a,b,c) # ? Does this work
  end

  def selection({:selection, type, price}, _loopdata) do
    Hardware.display("Please pay: #{price |> Integer.to_string}")
    {:next_state, :payment, {type, price, 0}}
  end

  def selection({:pay, coin }, loopdata) do
    Hardware.return_change(coin)
    {:next_state, :selection, loopdata}
  end

  def selection(_other, loopdata) do
    {:next_state, :selection, loopdata}
  end

  def payment({:pay, coin}, {type, price, paid}) when coin + paid < price do
    newpaid = coin + paid
    Hardware.display("Please pay: #{(price-newpaid) |> Integer.to_string}")
    {:next_state, :payment, {type, price, newpaid}}
  end

  def payment({:pay, coin}, {type, price, paid}) when coin + paid >= price do
    newpaid = coin + paid
    Hardware.display("Preparing drink.")
    Hardware.return_change(newpaid - price)
    Hardware.drop_cup()
    Hardware.prepare(type)
    Hardware.display("Remove Drink.")
    {:next_state, :remove, nil}
  end

  def payment(:cancel, {_type,_price,paid}) do
    Hardware.display("Make your selection")
    Hardware.return_change(paid)
    {:next_state, :selection, nil}
  end

  def payment(_other, loopdata) do
    {:next_state, :payment, loopdata}
  end

  def remove(:cup_removed, loopdata) do
    {:next_state, :selection, loopdata}
  end

  def remove({:pay, coin}, loopdata) do
    Hardware.return_change(coin)
    {:next_state, :remove, loopdata}
  end

  def remove(_other, loopdata) do
    {:next_state, :remove, loopdata}
  end

  def americano() do
    :gen_fsm.send_event __MODULE__, {:selection, :americano, 150}
  end

  def cappuccino() do
    :gen_fsm.send_event __MODULE__, {:selection, :cappuccino, 150}
  end

  def tea() do
    :gen_fsm.send_event __MODULE__, {:selection, :tea, 100}
  end

  def espresso() do
    :gen_fsm.send_event __MODULE__, {:selection, :espresso, 100}
  end

  def pay(coin) do
    :gen_fsm.send_event __MODULE__, {:pay, coin}
  end

  def cancel() do
    :gen_fsm.send_event __MODULE__, :cancel
  end

  def cup_removed() do
    :gen_fsm.send_event __MODULE__, :cup_removed
  end

  def handle_info(a,b) do
    {:noreply, nil}
  end

end