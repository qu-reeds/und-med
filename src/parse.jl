"""
Turn newline positions into ranges
"""
function LineRanges(newlines::Array{Int,1}, bom_offset::Int = 0)
  starts = vcat(1 + bom_offset, 1 + newlines[1:end-1])
  return [i:j for j in newlines, i in starts] |> diag
end

"""
Generate array of pseudo-pages
(fewer pseudo-pages detected than actual pages, must be errors)
"""
function PseudoPageRanges(docu::Array{String,1})
  pseudop_starts = find(x->startswith(x, "\f"), docu)
  pseudop_ends = pseudop_starts - 1
  prepend!(pseudop_starts, [1])
  # turns out this is wrong RE final page but use it for initial estimate:
  append!(pseudop_ends, length(docu))
  return [i:j for j in pseudop_ends, i in pseudop_starts] |> diag
end

to_ocr = joinpath(dirname(Base.source_path()), "../txt/ocr/ocr.txt")
to_p2t = joinpath(dirname(Base.source_path()), "../txt/ocr/p2t.txt")
to_lab = joinpath(dirname(Base.source_path()), "../txt/lab404/understanding_media.txt")

const global IS_NATIVE_LE = Base.ENDIAN_BOM == 0x04030201

function ReadTxt(txt_path::String)
  # store the bytes in the BOM position [may lack BOM altogether]
  bom_check = open(txt_path, "r") do f
    read(f, 2)
  end
  txtlines = open(txt_path, "r") do f
    if bom_check == [0xff, 0xfe]
      # utf-16le encoding detected, read bytes accordingly
      if IS_NATIVE_LE
        chars = map(Char, reinterpret(UInt16, read(f)))
        linebreaks = find(x->x == '\n', chars)
        lines = [chars[r] |> String for r in LineRanges(linebreaks, 1)]
        map(chomp, lines)
      else
        error("System [native] is big endian but encoding is UTF-16LE")
      end
    elseif bom_check == [0xfe, 0xff]
      error("File is UTF-16BE encoded, not coded for")
    else
      # proceed assuming UTF-8 encoding and no BOM
      map(chomp, readlines(f))
    end
  end;
end

ocr_ver = ReadTxt(to_ocr)
p2t_ver = ReadTxt(to_p2t)
lab_ver = ReadTxt(to_lab)
p2t_pseudo_pages = PseudoPageRanges(p2t_ver);
