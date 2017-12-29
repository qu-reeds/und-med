using Base.Test

include("../src/parse-toc.jl")

@test ReadTOC(to_toc) |> length == 13617
