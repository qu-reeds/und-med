using Base.Test

include("../src/parse.jl")

@test ReadTxt(to_p2t) |> length == 13617
@test ReadTxt(to_ocr) |> length == 2300
@test ReadTxt(to_lab) |> length == 11832
