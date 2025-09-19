@tool
extends Control

@onready var rtl: RichTextLabel = $RichTextLabel as RichTextLabel


func _ready() -> void:
	# Reset the size data so it's correct for whatever text it currently has
	# This is equivalent to changing the Anchor mode of "RichTextLabel" to full screen rect, and then back to "Position"
	# This then changes the "size" property so it matches the text
	rtl.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	rtl.set_anchors_preset(Control.PRESET_FULL_RECT, false)

	# When the label is resized, we need to update the shader to tell it how big it is now
	# Without this, the shader will never be able to generate the correct gradient
	# The shader is called per-glyph in the font file, so depending on the position of that
	# specific character in the font spritesheet, the UV's are different, and we can't use screen position either
	_on_resized()
	rtl.resized.connect(_on_resized)


func _on_resized():
	(rtl.material as ShaderMaterial).set_shader_parameter("rect_height", rtl.size.y)
