defmodule LbcparserTest do
  use ExUnit.Case

  @laguna_p1 File.read!("fixture/voitures_renault_laguna_3_midi_py.htm")
  @laguna_p2 File.read!("fixture/voitures_renault_laguna_3_midi_py_p2.htm")

  test "reads classifieds and skips ads" do
    expected = %{category: "(pro)", date: "Hier", id: "839541197",
      link: "http://www.leboncoin.fr/voitures/839541197.htm?ca=16_s",
      placement: [<<70, 114, 233, 106, 97, 105, 114, 111, 108, 108, 101, 115>>,
        "Tarn"], price: <<49, 57, 32, 53, 48, 48, 194, 160, 128>>, time: "08:38",
      title: "Renault Captur Intens 1.5 DCI 110 CV",
      picture: "voitures_renault_laguna_3_midi_py_files/51baad98c41aad89f6d74ac5b5acd121fa4c9907.jpg"}

    l = Lbcparser.parse @laguna_p1
    assert length(l) == 9
    assert List.first(l) == expected
  end
end
