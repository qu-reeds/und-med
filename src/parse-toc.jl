import DataStructures: OrderedDict
to_toc = joinpath(dirname(Base.source_path()), "../contents.mmt")

function ReadTOC(toc_path::String)
  lines = open(toc_path, "r") do f
    map(chomp, readlines(f))
  end
  toc_ind = MakeTocIndexes(lines)
  return Dict("lines" => lines, "indexed" => toc_ind)
end

function MakeTocIndexes(toc_lines::Array{String,1})
  ind = Dict()
  ind["parts"] = find(x->startswith(x, "-:"), toc_lines)
  append!(ind["parts"], find(x->startswith(x, "-,:"), toc_lines))
  ind["parts"] = map(x->x => GetPartInfo(toc_lines[x]), ind["parts"])
  ind["chapters"] = find(x->startswith(x, "-.."), toc_lines)
  append!(ind["chapters"], find(x->startswith(x, "-.,"), toc_lines))
  sort!(ind["chapters"])
  ind["chapters"] = map(x->GetChapterInfo(toc_lines[x])["n"] => GetChapterInfo(toc_lines[x]), ind["chapters"]) |> OrderedDict
  return ind
end

function GetChapterInfo(toc_line::String)
  ch_n = match(r"\[(\d+)\]", toc_line)
  ch_p = match(r"⠶\s(\d+)\s⠶", toc_line)
  ch_t = match(r"⠶\s(.+)$", toc_line, ch_p.offsets[1])
  return Dict("n" => parse(Int64, ch_n[1]),
	      "page" => parse(Int64, ch_p[1]),
	      "title" => ch_t[1])
end

function GetPartInfo(toc_line::String)
  pt_n = match(r"\[(.+)\]", toc_line)
  return Dict("n" => pt_n[1])
end

TOC = ReadTOC(to_toc);
