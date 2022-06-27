defmodule TripletDetector do
  require Logger

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
  Detect current node's triplet `ARCH-OS-ABI`.

  ## Example

    iex> TripletDetector.detect()

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
  Detect current node's triplet `ARCH-OS-ABI` in a custom range.

  ## Example

    # Only test if current node is x86_64-apple-darwin or arm64-apple-darwin
    iex> TripletDetector.detect(["x86_64-apple-darwin", "arm64-apple-darwin"])

    # {:error, :no_match} will be returned if there is no match
    iex> {:error, :no_match} = TripletDetector.detect(["not-exists"])
    iex> {:error, :no_match} = TripletDetector.detect([])

  """
  @spec detect([String.t()]) :: {:ok, String.t()} | {:error, :no_match}
  def detect([current | rest]) do
    func_name = String.to_atom(String.replace(current, "-", "_") <> "?")

    if Kernel.function_exported?(TripletDetector, func_name, 0) do
      case Kernel.apply(TripletDetector, func_name, []) do
        true -> {:ok, current}
        false -> detect(rest)
      end
    else
      {:error, :no_match}
    end
  end

  def detect([]), do: {:error, :no_match}

  @spec fetch_triplets(nil | [String.t()], String.t()) :: :ok | {:error, term()}
  def fetch_triplets([triplet | rest], save_to) when is_binary(triplet) do
    filename = "#{triplet}.so"

    url =
      "#{TripletDetector.MixProject.github_url()}/releases/download/precompiled-artefacts-v#{TripletDetector.MixProject.precompiled_artefacts_version()}/#{filename}"

    priv_so = Path.join([save_to, filename])

    with {:create_priv_dir, :ok} <- {:create_priv_dir, File.mkdir_p(save_to)},
         {:priv_so_exists, false} <- {:priv_so_exists, File.exists?(priv_so)},
         {:download_artefacts, {:ok, so_data}} <- {:download_artefacts, download_artefact(url)},
         {:save_so, :ok} <- {:save_so, File.write(priv_so, so_data)} do
      fetch_triplets(rest, save_to)
    else
      {:create_priv_dir, status} ->
        Logger.error("Failed to create directory: #{inspect(status)}")
        {:error, status}

      {:priv_so_exists, true} ->
        fetch_triplets(rest, save_to)

      {:download_artefacts, {:ssl_status, status}} ->
        Logger.error("Failed to start ssl: #{inspect(status)}")
        {:error, status}

      {:download_artefacts, {:inet_status, status}} ->
        Logger.error("Failed to start inet: #{inspect(status)}")
        {:error, status}

      {:download_artefacts, status} ->
        Logger.error("Failed to download artefact from #{url}: #{inspect(status)}")
        {:error, status}

      {:save_so, status} ->
        error = "Failed to save downloaded file: #{inspect(status)}"
        Logger.error(error)
        {:error, error}
    end
  end

  def fetch_triplets([], _), do: :ok

  def fetch_triplets(nil, _) do
    Logger.warn("No precompiled shared libraries is prefetched in compile-time")
  end

  defp download_artefact(url) do
    Logger.info("Downloading artefact from #{url}")

    http_opts = []
    opts = [body_format: :binary]
    arg = {url, []}

    with {:ssl_status, :ok} <- {:ssl_status, :ssl.start()},
         {:inet_status, :ok} <-
           {:inet_status,
            case :inets.start() do
              :ok -> :ok
              {:error, {:already_started, :inets}} -> :ok
              status -> status
            end} do
      case :httpc.request(:get, arg, http_opts, opts) do
        {:ok, {{_, 200, _}, _, body}} ->
          {:ok, body}

        status ->
          status
      end
    else
      status -> status
    end
  end

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
