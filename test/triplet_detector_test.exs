defmodule TripletDetectorTest do
  use ExUnit.Case
  doctest TripletDetector

  test "Return value must be an ok-error tuple" do
    return_ok_error =
       case TripletDetector.detect() do
        {:ok, triplet} when is_binary(triplet) -> true
        {:error, "unknown"} -> true
        _ -> false
      end
    assert true = return_ok_error
  end

  test "Test not existing candidate triplets" do
    assert {:error, "unknown"} = TripletDetector.detect([])
    assert {:error, "unknown"} = TripletDetector.detect(["not-exists"])
  end
end
