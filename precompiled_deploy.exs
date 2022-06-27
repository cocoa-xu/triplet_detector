defmodule TripletDetector.PrecompiledDeploy do
  @moduledoc false

  def app_priv do
    "#{Mix.Project.app_path(Mix.Project.config())}/priv"
  end

  def deploy do
    config = Mix.Project.config()
    triplets = config[:triplets] || TripletDetector.all_triplets
    TripletDetector.fetch_triplets(triplets, app_priv())
  end
end

TripletDetector.PrecompiledDeploy.deploy()
