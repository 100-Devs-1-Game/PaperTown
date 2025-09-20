@tool
class_name RichTextTiltEffect
extends RichTextEffect

# To use this effect:
# - Enable BBCode on a RichTextLabel.
# - Register this effect on the label.
# - Use [tilt]hello[/tilt_effect] in text.
var bbcode := "tilt"

var a := 0


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# I only vaguely understood what's going on here
	# but basically, lots of hacks to make the text wobble a bit
	# TL;DR the transform origin is the label's corner, not the glyphs center
	# so we have to do some stuff to work around that... otherwise it would be easy
	# WARNING: MSDF (multichannel signed distance field fonts) have a different glyph_size???
	#   which then breaks the tilt origin... so, something to watch out
	#   (it also breaks the gradient btw)

	var ts := TextServerManager.get_primary_interface()
	var glyph_size := ts.font_get_glyph_size(char_fx.font, Vector2i(160, 0), char_fx.glyph_index)
	var pivot := Vector2(glyph_size.x * 0.5, glyph_size.y * 0.5)
	var angle := 0.1 * sin(char_fx.elapsed_time * 6.0 + float(char_fx.relative_index))
	char_fx.transform = (
		char_fx.transform
		* Transform2D(0, pivot)
		* Transform2D(angle, Vector2.ZERO)
		* Transform2D(0, -pivot)
	)

	return true
