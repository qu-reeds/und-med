using Base.Test

include("../src/parse-toc.jl")

@test ReadTOC(to_toc)["lines"] |> length == 37
@test TOC["indexed"]["chapters"] |> length == map(m->find(x->startswith(x, m), ReadTOC(to_toc)["lines"]) |> length, ["-..", "-.,"]) |> sum
