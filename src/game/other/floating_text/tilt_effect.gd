@tool
class_name RichTextTiltEffect
extends RichTextEffect

# To use this effect:
# - Enable BBCode on a RichTextLabel.
# - Register this effect on the label.
# - Use [tilt]hello[/tilt_effect] in text.
var bbcode := "tilt"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var ts := TextServerManager.get_primary_interface()
	var glyph_size := ts.font_get_glyph_size(char_fx.font, Vector2i(160, 0), char_fx.glyph_index)
	var pivot := Vector2(glyph_size.x * 0.5, 0.0)
	var angle := 0.1 * sin(char_fx.elapsed_time * 3.0 + float(char_fx.relative_index))

	var xf := char_fx.transform
	xf = xf * Transform2D(0, pivot / 2.0)
	xf = xf * Transform2D(angle, Vector2.ZERO)
	xf = xf * Transform2D(0, -pivot / 2.0)

	char_fx.transform = xf

	return true
