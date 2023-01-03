defmodule Satie.Markup do
  @moduledoc """
  Models arbitrarily nested markup
  """

  alias __MODULE__.ComponentHelpers
  require __MODULE__.FunctionBuilder
  import __MODULE__.FunctionBuilder

  use Satie.Attachable, fields: [:content]

  def new(content) do
    %__MODULE__{
      content: content
    }
    |> ComponentHelpers.build_component()
  end

  ###########
  ## FONT ##
  ###########

  build_function :bold
  build_function :caps
  build_function :dynamic
  build_function "figured-bass"
  build_function :finger
  build_function "fontCaps"
  build_function :huge
  build_function :italic
  build_function :large
  build_function :larger
  build_function :magnify, :sz
  build_function :medium
  build_function "normal-text"
  build_function :normalsize
  build_function :number
  build_function :roman
  build_function :sans
  build_function :simple
  build_function :small
  build_function "smallCaps"
  build_function :smaller
  build_function :teeny
  build_function :text
  build_function :tiny
  build_function :typewriter
  build_function :upright

  build_function_with_overrides "abs-fontsize", size, ~w(baseline-skip word-space)
  build_function_with_overrides :box, ~w(box-padding font-size thickness)
  build_function_with_overrides :fontsize, increment, ~w(baseline-skip word-space font-size)
  build_function_with_overrides "normal-size-sub", ~w(font-size)
  build_function_with_overrides "normal-size-super", ~w(font-size)
  build_function_with_overrides :overtie, ~w(shorten-pair height-limit direction offset thickness)
  build_function_with_overrides :sub, ~w(font-size)
  build_function_with_overrides :super, ~w(font-size)
  build_function_with_overrides :tie, ~w(shorten-pair height-limit direction offset thickness)
  build_function_with_overrides :underline, ~w(underline-skip underline-shift offset thickness)

  build_function_with_overrides :undertie,
                                ~w(shorten-pair height-limit direction offset thickness)

  ############
  ## ALIGN ##
  ############

  build_function "center-align"
  build_function "center-column"
  build_function :column
  build_function :concat
  build_function "general-align", [axis, dir]
  build_function :halign, dir
  build_function "hcenter-in", length
  build_function "left-align"
  build_function :lower, amount
  build_function :overlay
  build_function :pad, amount
  build_function "pad-around", amount
  build_function "pad-to-box", [x_ext, y_ext]
  build_function "pad-x", amount
  build_function :raise, amount
  build_function "right-align"
  build_function :rotate, ang
  build_function :translate, offset
  build_function :vcenter

  build_entity :hspace, amount
  build_entity :vspace, amount

  build_function_with_overrides "dir-column", ~w(baseline-skip direction)
  build_function_with_overrides "fill-line", ~w(line-width word-space text-direction)
  build_function_with_overrides :justify, ~w(text-direction word-space line-width baseline-skip)
  build_function_with_overrides "justify-line", ~w(text-direction word-space line-width)
  build_function_with_overrides "left-column", ~w(baseline-skip)
  build_function_with_overrides "line", ~w(text-direction word-space)
  build_function_with_overrides "right-column", ~w(baseline-skip)
  build_function_with_overrides "translate-scaled", offset, ~w(font-size)
  build_function_with_overrides :wordwrap, ~w(text-direction word-space line-width baseline-skip)

  ##############
  ## GRAPHIC ##
  ##############

  build_entity "arrow-head", [axis, direction, filled]
  build_entity :beam, [width, slope, thickness]
  build_entity "draw-circle", [radius, thickness, filled]
  build_entity "eps-file", [axis, size, file_name]
  build_entity "filled-box", [xext, yext, blot]

  build_entity_with_overrides "draw-dashed-line", dest, ~w(full-length phase off on thickness)
  build_entity_with_overrides "draw-dotted-line", dest, ~w(phase off thickness)
  build_entity_with_overrides "draw-hline", ~w(span-factor line-width draw-line-markup)
  build_entity_with_overrides "draw-line", dest, ~w(thickness)

  build_entity_with_overrides "draw-squiggle-line",
                              [sq_length, dest, eq_end],
                              ~w(orientation height angularity thickness)

  build_entity_with_overrides :triangle, filled, ~w(thickness font-size extroversion)

  build_function :bracket
  build_function :hbracket
  build_function :scale, factor_pair
  build_function "with-url", url

  build_function_with_overrides :circle, ~w(circle-padding font-size thickness)
  build_function_with_overrides :ellipse, ~w(x-padding y-padding font-size thickness)
  build_function_with_overrides :oval, ~w(x-padding y-padding font-size thickness)

  build_function_with_overrides :parenthesize,
                                ~w(width line-thickness thickness size padding angularity)

  build_function_with_overrides "rounded-box", ~w(box-padding font-size corner-radius thickness)

  ############
  ## MUSIC ##
  ############

  build_entity :coda
  build_entity "customTabClef", [num_strings, staff_space]
  build_entity :doubleflat
  build_entity :doublesharp
  build_entity :flat
  build_entity :musicglyph, glyph_name
  build_entity :natural
  build_entity :segno
  build_entity :semiflat
  build_entity :semisharp
  build_entity :sesquiflat
  build_entity :sesquisharp
  build_entity :sharp
  build_entity :varcoda

  build_entity_with_overrides :fermata, ~w(direction)

  build_entity_with_overrides "multi-measure-rest-with-overrides",
                              duration_scale,
                              ~w(multi-measure-rest-number width expand-limit hair-thickness thick-thickness word-space style font-size)

  build_entity_with_overrides :note,
                              [duration, dir],
                              ~w(style dots-direction flag-style font-size)

  build_entity_with_overrides "note-by-number",
                              [log, dot_count, dir],
                              ~w(style dots-direction flag-style font-size)

  build_entity_with_overrides :rest,
                              [duration],
                              ~w(multi-measure-rest-number width expand-limit hair-thickness thick-thickness word-space style font-size ledgers)

  build_entity_with_overrides "rest-by-number", [log, dot_count], ~w(style ledgers font-size)

  build_entity_with_overrides "tied-lyric", str, ~w(word-space)

  ############
  ## OTHER ##
  ############

  build_entity :eyeglasses
  build_entity "left-brace", size
  build_entity :markalphabet, num
  build_entity :markletter, num
  build_entity :null
  build_entity :pattern, [count, axis, space, pattern]
  build_entity "right-brace", size
  build_entity :strut
  build_entity "verbatim-file", name

  build_entity_with_overrides "backslashed-digit", ~w(thickness font-size)
  build_entity_with_overrides "slashed-digit", ~w(thickness font-size)

  build_function :transparent
  build_function "with-color", color

  build_function_with_overrides :whiteout, ~w(thickness style)

  # TODO:
  # FONT
  # - replace
  # - with-string-transformer
  # ALIGN
  # - align-on-other
  # - combine
  # - fill-with-pattern
  # - justify-field
  # - justify-string
  # - put-adjacent
  # - wordwrap-field
  # - wordwrap-string
  # GRAPHIC
  # - path
  # - polygon
  # - postscript
  # MUSIC
  # - accidental
  # - compound-meter
  # - rhythm
  # - score
  # OTHER
  # - auto-footnote
  # - char
  # - first-visible
  # - footnote
  # - fraction
  # - fromproperty
  # - lookup
  # - on-the-fly
  # - override
  # - page-link
  # - page-ref
  # - property-recursive
  # - stencil
  # - with-dimensions-from
  # - with-dimensions
  # - with-link
  # - with-outline
end
