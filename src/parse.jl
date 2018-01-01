include("parse-toc.jl")

"""
Turn newline positions into ranges
"""
function LineRanges(newlines::Array{Int,1}, bom_offset::Int = 0)
  starts = vcat(1 + bom_offset, 1 + newlines[1:end-1])
  return [i:j for j in newlines, i in starts] |> diag
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

"""
Index pages (via \f characters) and chapters (using TOC), according to an
offset (the page the first listed chapter begins on) and an end point (the
page the last listed chapter ends on) - both using PDF not TOC numbering.
For UM, Ch. 0 (Introduction, unnumbered in the book) begins on book p.3
(p.25 of the PDF), and Ch. 34 (Further Readings, also unnumbered in the
book) ends on page 365 (p. 387 of the PDF).
"""
function IndexPgCh(docu::Array{String,1}, pdf_pg_start::Int, pdf_pg_end::Int)
  # note that final form feed is erroneous so index it away
  pages = map(x->split(x, "\n"), split(join(p2t_ver, '\n'), "\f"))[1:end-1]
  ch_list = TOC["indexed"]["chapters"]
  first_ch = ch_list.keys[1] # 0
  first_ch_start_p = ch_list[first_ch]["page"]
  pdf_pg_increment = pg_offset - first_ch_start_p
  
end

ocr_ver = ReadTxt(to_ocr)
p2t_ver = ReadTxt(to_p2t)
p2t_pages = IndexPgCh(p2t_ver, 25, 387)
lab_ver = ReadTxt(to_lab)
