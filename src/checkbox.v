module iui

import gg
import gx

// Checkbox - implements Component interface
pub struct Checkbox {
	Component_A
pub mut:
	app            &Window
	text           string
	click_event_fn fn (mut Window, Checkbox)
}

[params]
pub struct CheckboxConfig {
	bounds    Bounds
	user_data voidptr
	selected  bool
	text      string
}

pub fn check_box(conf CheckboxConfig) &Checkbox {
	return &Checkbox{
		text: conf.text
		app: unsafe { nil }
		x: conf.bounds.x
		y: conf.bounds.y
		width: conf.bounds.width
		height: conf.bounds.height
		is_selected: conf.selected
		click_event_fn: blank_event_cbox
	}
}

[deprecated: 'Use check_box(CheckboxConfig)']
pub fn checkbox(app &Window, text string, conf CheckboxConfig) Checkbox {
	return Checkbox{
		text: text
		app: app
		x: conf.bounds.x
		y: conf.bounds.y
		width: conf.bounds.width
		height: conf.bounds.height
		is_selected: conf.selected
		click_event_fn: blank_event_cbox
	}
}

pub fn (mut com Checkbox) set_click(b fn (mut Window, Checkbox)) {
	com.click_event_fn = b
}

pub fn blank_event_cbox(mut win Window, a Checkbox) {
}

// Get border color
fn (this &Checkbox) get_border(is_hover bool, ctx &GraphicsContext) gx.Color {
	if this.is_mouse_down {
		return ctx.theme.button_border_click
	}

	if is_hover {
		return ctx.theme.button_border_hover
	}
	return ctx.theme.button_border_normal
}

// Get background color
fn (this &Checkbox) get_background(is_hover bool, ctx &GraphicsContext) gx.Color {
	if this.is_mouse_down {
		return ctx.theme.button_bg_click
	}

	if is_hover {
		return ctx.theme.button_bg_hover
	}
	return ctx.theme.checkbox_bg
}

// Draw checkbox
pub fn (mut com Checkbox) draw(ctx &GraphicsContext) {
	// Draw Background & Border
	com.draw_background(ctx)

	// Detect click
	if com.is_mouse_rele {
		com.is_mouse_rele = false
		com.is_selected = !com.is_selected
		mut win := ctx.win
		com.click_event_fn(mut win, *com)
	}

	// Draw checkmark
	if com.is_selected {
		com.draw_checkmark(ctx)
	}

	// Draw text
	com.draw_text(ctx)
}

// Draw background & border of Checkbox
fn (com &Checkbox) draw_background(ctx &GraphicsContext) {
	half_wid := com.width / 2
	half_hei := com.height / 2

	mid := com.x + half_wid
	midy := com.y + half_hei

	is_hover_x := abs(mid - ctx.win.mouse_x) < half_wid
	is_hover_y := abs(midy - ctx.win.mouse_y) < half_hei
	is_hover := is_hover_x && is_hover_y

	bg := com.get_background(is_hover, ctx)
	border := com.get_border(is_hover, ctx)

	ctx.win.draw_bordered_rect(com.x, com.y, com.height, com.height, 0, bg, border)
}

// Draw the text of Checkbox
fn (this &Checkbox) draw_text(ctx &GraphicsContext) {
	sizh := ctx.gg.text_height(this.text) / 2
	ctx.draw_text(this.x + this.height + 4, this.y + (this.height / 2) - sizh, this.text,
		ctx.font, gx.TextCfg{
		size: ctx.font_size
		color: ctx.theme.text_color
	})
}

// TODO: Better Checkmark
fn (com &Checkbox) draw_checkmark(ctx &GraphicsContext) {
	cut := 3
	wid := com.height - (cut * 2) - 1
	ctx.gg.draw_rounded_rect_filled(com.x + cut, com.y + cut, wid, wid, 2, ctx.theme.checkbox_selected)
}
