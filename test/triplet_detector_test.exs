defmodule TripletDetectorTest do
  use ExUnit.Case
  doctest TripletDetector

  test "Test current node's triplet" do
    TripletDetector.detect()
  end
end
