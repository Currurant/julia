# This file is a part of Julia. License is MIT: https://julialang.org/license

# Call Julia's builtin flisp-based parser. `offset` is 0-based offset into the
# byte buffer or string.
function fl_parse(text::Union{Core.SimpleVector,String},
                  filename::String, offset, options)
    if text isa Core.SimpleVector
        # Will be generated by C entry points jl_parse_string etc
        text, text_len = text
    else
        text_len = sizeof(text)
    end
    ccall(:jl_fl_parse, Any, (Ptr{UInt8}, Csize_t, Any, Csize_t, Any),
          text, text_len, filename, offset, options)
end

function fl_parse(text::AbstractString, filename::AbstractString, offset, options)
    fl_parse(String(text), String(filename), offset, options)
end

"""
    set_parser(func)

Swap the parser used for all juila code to the given `func`.

When installing a parser, it may be appropriate to freeze it to a given world
age using Base.get_world_counter and the Core._apply_in_world builtin.

!!! note
    Experimental! May be removed at any time.
"""
function set_parser(func)
    global _parser = func
end

_parser = fl_parse

"""
    parse(text, filename, offset, options)

Parse Julia code from the buffer `text`, starting at `offset` and attributing
it to `filename`. `options` should be one of `:atom`, `:statement` or `:all`,
indicating how much the parser will consume.

`parse` returns an `svec` containing an `Expr` and the new offset as an `Int`.

Bootstrap note: See jl_parse which will call into Core.Compiler.parse as soon
as it's defined.

!!! note
    Experimental! May be removed at any time.
"""
function parse(text, filename, offset, options)
    _parser(text, filename, offset, options)
end
