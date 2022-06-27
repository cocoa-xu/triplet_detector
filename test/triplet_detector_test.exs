defmodule TripletDetectorTest do
  use ExUnit.Case
  doctest TripletDetector

  test "Test current machine's triplet" do
    TripletDetector.detect()
  end
end
