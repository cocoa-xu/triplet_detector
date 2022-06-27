defmodule TripletDetector do
  @all_linux_triplets [
    "x86_64-linux-gnu",
    "aarch64-linux-gnu",
    "arm-linux-gnueabihf",
    "riscv64-linux-gnu",
    "s390x-linux-gnu",
    "powerpc64le-linux-gnu"
  ]
  @all_apple_triplets [
    "x86_64-apple-darwin",
    "arm64-apple-darwin"
  ]
  @all_triplets @all_linux_triplets ++ @all_apple_triplets

  @doc """
  All available Linux triplets
  """
  @spec all_linux_triplets() :: [String.t()]
  def all_linux_triplets, do: @all_linux_triplets

  @doc """
  All available macOS triplets
  """
  @spec all_apple_triplets() :: [String.t()]
  def all_apple_triplets, do: @all_apple_triplets

  @doc """
  All available triplets
  """
  @spec all_triplets() :: [String.t()]
  def all_triplets, do: @all_triplets

  @doc """
  Detect current machine's triplet `ARCH-OS-ABI`.
  """
  @spec detect() :: {:ok, String.t()} | {:error, :no_match}
  def detect do
    case :os.type() do
      {:unix, :darwin} -> detect(@all_apple_triplets)
      {:unix, _} -> detect(@all_linux_triplets)
      {:win32, _} -> {:error, :no_match}
    end
  end

  @doc """
  Detect current machine's triplet `ARCH-OS-ABI` in a custom range.
  """
  @spec detect([String.t()]) :: {:ok, String.t()} | {:error, :no_match}
  def detect([current | rest]) do
    func_name = String.to_atom(String.replace(current, "-", "_") <> "?")

    case Kernel.apply(TripletDetector, func_name, []) do
      true -> {:ok, current}
      false -> detect(rest)
    end
  end

  def detect([]), do: {:error, :no_match}

  for triplet <- @all_triplets do
    func_name = String.replace(triplet, "-", "_")
    @triplet_name triplet
    @doc """
    Test for #{triplet}
    """
    @spec unquote(:"#{func_name}?")(String.t()) :: true | false
    def unquote(:"#{func_name}?")(base_dir \\ :code.priv_dir(:triplet_detector)) do
      path = '#{Path.join([base_dir, @triplet_name])}'
      try_load_nif(path)
    end
  end

  @spec try_load_nif(term()) :: true | false
  defp try_load_nif(path) when is_list(path), do: try_load_nif(:erlang.load_nif(path, 0))
  defp try_load_nif({:error, {:bad_lib, _}}), do: true
  defp try_load_nif({:error, _}), do: false
  defp try_load_nif(_), do: false
end
