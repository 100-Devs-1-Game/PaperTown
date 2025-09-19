# Floating Text

This is designed specifically for paper mario kinda text, but let me explain what's going, because it's very messy and confusing

This is working around a few different hacks:
	- There's no RichTextLabel3D
	- There's no way to set a gradient for the font colour

So we use a shader for the gradient, after some more hacks to generate it correctly
But we also have a hack to get the rich text label size to update based on its contents

we have to use that label size as a Subviewport size, to make it work as a 3D node

The stylebox is used to set a margin between the label and its boundary, so when it wobbles, it won't clip outside of it

The text might now be visible in the editor, or may look wrong, but it will look correct in the game

TODO:
	- Expose RichTextLabel properties on FloatingText3D
	- Expose Colours on FloatingText3D (e.g outline border and gradient)
	- Shadows?
	- Tweens?
	- Spawning floating text easily?
