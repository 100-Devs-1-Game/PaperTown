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

	var ts := TextServerManager.get_primary_interface()
	var glyph_size := ts.font_get_glyph_size(char_fx.font, Vector2i(160, 0), char_fx.glyph_index)
	var _pivot := Vector2(glyph_size.x * 0.5, glyph_size.y * 0.5)
	var angle := 0.1 * sin(char_fx.elapsed_time * 6.0 + float(char_fx.relative_index))

	var xf := char_fx.transform
	#todo: the pivits cause it to stutter/jitter
	var xf2 = xf  # * Transform2D(0, pivot)
	var xf3 = xf2 * Transform2D(angle, Vector2.ZERO)
	var xf4 = xf3  # * Transform2D(0, -pivot)
	var xf5 = xf4
	#xf5.origin.x = floor(xf4.origin.x)
	#xf5.origin.y = floor(xf4.origin.y)
	#print("\nxf1 %s\nxf2 %s\nxf3 %s\nxf4 %s\nxf5 %s\n" % [xf, xf2, xf3, xf4, xf5])

	char_fx.transform = xf5

	return true
