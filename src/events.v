module iui

// TODO:
// List of events:
//	Action      - https://docs.oracle.com/javase/7/docs/api/java/awt/event/ActionEvent.html
//	Mouse       - https://docs.oracle.com/javase/7/docs/api/java/awt/event/MouseEvent.html
//	Key         - https://docs.oracle.com/javase/7/docs/api/java/awt/event/KeyEvent.html
//	Resize/Move - https://docs.oracle.com/javase/7/docs/api/java/awt/event/ComponentEvent.html
pub struct Event {
}

pub struct ComponentEvent {
	Event
pub mut:
	ctx    &GraphicsContext
	target &Component
}

pub fn (e &ComponentEvent) get_target[T]() &T {
	mut tar := e.target

	if mut tar is T {
		return tar
	}
	return unsafe { nil }
}

// During on component draw
pub struct DrawEvent {
	ComponentEvent
}

// Mouse move, pressed, released, dragged, etc.
pub struct MouseEvent {
	ComponentEvent // TODO button type, down up, etc.
}

pub struct MouseEvent2[T] {
	MouseEvent
pub mut:
	target &T
}

// When user clicks a button, presses Enter in a text field, etc.
pub struct ActionEvent {
	ComponentEvent
}

// Key pressed, released
pub struct KeyEvent {
	ComponentEvent
}

// Draw line event
pub struct DrawTextlineEvent {
	DrawEvent
pub:
	line int
	x    int
	y    int
}

// Selectbox change event
pub struct ItemChangeEvent {
	ComponentEvent
pub:
	old_val string
	new_val string
}

// Scroll
pub struct ScrollEvent {
	ComponentEvent
	delta int
	dir   i8
}

// Text change
pub struct TextChangeEvent {
	ComponentEvent
pub mut:
	cancel bool
}

// Slider Change
pub struct FloatValueChangeEvent {
	ComponentEvent
pub mut:
	target &Slider
	value  f32
}
