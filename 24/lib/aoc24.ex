defmodule Aoc24 do
  @moduledoc """
  Documentation for `Aoc24`.
  """

  @doc """
  Hello world.

  ## Examples

  """

  import Bitwise

  require Record
  Record.defrecord(:gate, [:in1, :in2, :op, :out])

  def run(_args) do
    {inits, gates} = Aoc24.File.read_file("input.txt")
    setup_init_vals(inits)
    setup_gates(gates)

    xs = x_inputs(inits) |> read_regs() |> regs_to_int()
    ys = y_inputs(inits) |> read_regs() |> regs_to_int()
    rs = xs + ys
    outputs = output_gates(gates)
    eval(outputs)
    regs = read_regs(outputs)

    res = regs_to_int(regs) |> IO.inspect(label: :result)

    check_result(rs, res)

    {length(inits), length(gates), length(outputs), :ets.info(:vals, :size), :ets.info(:gates, :size)}

  end

  def check_result(rs, res) do
    check_result(rs, res, 0)
  end

  def check_result(0, 0, _ix), do: true
  def check_result(rs, res, _ix) when rs == 0 or res == 0, do: IO.inspect("WHAT!") ; false
  def check_result(rs, res, ix) do
    b1 = band(rs, 1)
    b2 = band(res, 1)
    case b1 == b2 do
      true -> :ok
      false -> IO.inspect("bit #{ix} differs, #{b1} vs #{b2}")
    end
    check_result(rs >>> 1, res >>> 1, ix+1)
  end


  def regs_to_int(regs) do
    Enum.reverse(regs) |> Enum.reduce(0, &bin2int/2)
  end

  def bin2int(reg, acc) do
    2*acc+reg
  end

  def read_regs(regs) do
    Enum.map(regs, &val/1)
  end

  def eval(wires) when is_list(wires), do: Enum.map(wires, &eval/1)
  def eval(wire) when is_binary(wire) do
    case val(wire) do
      nil -> eval_gate(wire)
      val -> val
    end
  end

  def eval_gate(wire) do
    [g] = :ets.lookup(:gates, wire)
    v1 = eval(in1(g))
    v2 =eval(in2(g))
    res = op(op(g), v1, v2)
    set_val(out(g), res)
    res
  end

  def op(:AND, in1, in2), do: band(in1, in2)
  def op(:OR, in1, in2), do: bor(in1, in2)
  def op(:XOR, in1, in2), do: bxor(in1, in2)


  def output_gates(gates) do
    Enum.filter(gates, &is_output/1) |> Enum.map(&out/1) |> Enum.sort()
  end

  def is_output(g) when Record.is_record(g, :gate), do: is_output(out(g))
  def is_output(out), do: String.slice(out, 0, 1) == "z"

  def input_gates(inits) do
    inits |> Enum.map(fn(x) -> elem(x, 0) end) |> Enum.sort()
  end

  def x_inputs(inits), do: c_inputs(inits, "x")
  def y_inputs(inits), do: c_inputs(inits, "y")
  def c_inputs(inits, c) do
    inits |> input_gates() |> Enum.filter(fn(x) -> String.slice(x, 0, 1) == c end)
  end

  def is_input(g) when Record.is_record(g, :gate), do: is_input(out(g))
  def is_input(out), do: String.slice(out, 0, 1) == "x" || String.slice(out, 0, 1) == "y"

  def setup_gates(gates) do
    new_tab(:gates, keypos: gate(:out) + 1)  ## +1 because Iex is 0 based, erl is 1 based
    Enum.each(gates, fn g -> :ets.insert(:gates, g) end)
  end

  def val(wire) do
    case :ets.lookup(:vals, wire) do
      [] -> nil
      [{_, val}] -> val
    end
  end

  def set_val(wire, val) do
      :ets.insert(:vals, {wire, val})
  end

  def setup_init_vals(inits) do
    new_tab(:vals)
    Enum.each(inits, fn init -> :ets.insert(:vals, init) end)
  end

  def new_tab(name) do
    new_tab(name, [])
  end

  def new_tab(name, opts) do
    case :ets.whereis(name) do
      :undefined -> :ok
      _ -> :ets.delete(name)
    end
    :ets.new(name, [:named_table | opts])
  end

  def in1(g), do: gate(g, :in1)
  def in2(g), do: gate(g, :in2)
  def op(g), do: gate(g, :op)
  def out(g), do: gate(g, :out)

end
