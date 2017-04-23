defmodule Coffee do
  @moduledoc false

  use GenEvent

  def start_link do
    {:ok, spawn_link(__MODULE__, :init, [])}
  end

  def init do
    register(__MODULE__, self())
    Hardware.reboot()
    Hardware.display("Make your selection",[])
    selection()
  end

  # Client functions for drink selections

  def tea(),        do: send __MODULE__, {:selection, :tea, 100}
  def espresso(),   do: send __MODULE__, {:selection, :espresso, 150}
  def americano(),  do: send __MODULE__, {:selection, :americano, 100}
  def cappuchino(), do: send __MODULE__, {:selection, :cappuchino, 150}

  # Client functions for actions

  def cup_removed(), do: send __MODULE__, :cup_removed
  def pay(coin),     do: send __MODULE__, {:pay, coin}
  def cancel(),      do: send __MODULE__, :cancel

  def selection() do
    receive do
      {:selection, type, price} ->
        Hardware.display("Please pay #{price}")
        payment(type, price, 0)
      {:pay, coin} ->
        Hardware.return_change(coin)
        selection()
      _ -> % cancel
          selection()
    end
  end

  def payment(type, price, paid) do
    receive do
      {:pay, coin} ->
        if coin + paid >= price do
           Hardware.display("Preparing Drink")
           Hardware.return_change(coin + paid - price)
           Hardware.drop_cup()
           Hardware.display("Remove Drink", [])
           remove()
        else
           topay = price - (coin + paid)
           Hardware.display("Please pay: #{price}", [])
           payment(type, price, coin + paid)
        end
      :cancel ->
        Hardware.display("Make your selection", [])
        Hardware.return_change(paid)
        selecton()
      _ -> #selection
        payment(type, price, paid)
    end
  end

  def remove() do
    receive do
      :cup_removed ->
        Hardware.display("Make your selection", [])
        selection()
      {:pay, coin} ->
        Hardware.return_change(coin)
        remove()
      _ -> # cancel/selection
        remove()
    end
  end

  def process_flag(a, b) do
    #WTF?
  end

end