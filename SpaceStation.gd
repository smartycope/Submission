class_name SimpleTextureButton
extends TextureButton

# export var texture: Texture
export var pressedColor = Color(50, 50, 50, 20)
export var hoverColor = Color(200, 200, 200, 20)
export var disabledColor = Color(20, 20, 20, 100)
export var focusedColor = Color(0, 0, 0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
    var image = texture_normal.get_data()

    var pressedImage = Image.new()
    pressedImage.create(image.get_width(), image.get_height(), false, image.get_format())
    pressedImage.fill(pressedColor)
    texture_pressed = image.blend_rect_mask(image.duplicate(), pressedImage, image.get_used_rect(), Vector2(0, 0))

    var hoverImage = Image.new()
    hoverImage.create(image.get_width(), image.get_height(), false, image.get_format())
    hoverImage.fill(hoverColor)
    texture_hover = image.blend_rect_mask(image.duplicate(), hoverImage, image.get_used_rect(), Vector2(0, 0))

    var disabledImage = Image.new()
    disabledImage.create(image.get_width(), image.get_height(), false, image.get_format())
    disabledImage.fill(disabledColor)
    texture_disabled = image.blend_rect_mask(image.duplicate(), disabledImage, image.get_used_rect(), Vector2(0, 0))

    var focusedImage = Image.new()
    focusedImage.create(image.get_width(), image.get_height(), false, image.get_format())
    focusedImage.fill(focusedColor)
    texture_focused = image.blend_rect_mask(image.duplicate(), focusedImage, image.get_used_rect(), Vector2(0, 0))
    # texture_hover
    # texture_disabled
    # texture_focused





