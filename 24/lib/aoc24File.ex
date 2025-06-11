defmodule Aoc24.File do
  @moduledoc """
  Documentation for `Aoc24`.
  """
  import Aoc24


  ## Read file and basic parsing
  def read_file(fname) do
    File.read!(fname) |> String.split("\n") |> parse_lines() |> split_in_init_and_gates()
  end

  def split_in_init_and_gates(gates) do
    Enum.reduce(gates, {[], []}, &split_init_gate/2)
  end

  def split_init_gate(nil, gts), do: gts
  def split_init_gate(i = {_, _}, {is, gs}), do: {[i | is], gs}
  def split_init_gate(g, {is, gs}), do: {is, [g | gs]}


  def parse_lines(lines) do
    Enum.map(lines, &parse_line/1)
  end

  def parse_line(line) do
    case String.split(line, " ") do
      toks when length(toks) == 2 -> parse_init(toks)
      toks when length(toks) == 5 -> parse_gate(toks)
      _ -> nil
    end
  end

  def parse_init([x, y]) do
    {String.slice(x, 0, 3), String.to_integer(y)}
  end

  def parse_gate([i1, cmd, i2, _, out]) do
    gate(in1: i1, op: String.to_atom(cmd), in2: i2, out: out)
  end

  def in1(g), do: gate(g, :in1)
  def in2(g), do: gate(g, :in2)
  def op(g), do: gate(g, :op)
  def out(g), do: gate(g, :out)

end
