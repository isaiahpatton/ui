module iui

import gx

// Select - implements Component interface
pub struct Selectbox {
	Component_A
pub mut:
	app        &Window
	text       string
	items      []string
	show_items bool
	center     bool
	sub_height int = 28
	popup      &Popup
}

@[params]
pub struct SelectboxConfig {
pub:
	bounds Bounds
	items  []string
	text   string
}

pub fn Selectbox.new(cfg SelectboxConfig) &Selectbox {
	return &Selectbox{
		text:   cfg.text
		app:    unsafe { nil }
		x:      cfg.bounds.x
		y:      cfg.bounds.y
		width:  cfg.bounds.width
		height: cfg.bounds.height
		items:  cfg.items
		popup:  unsafe { nil }
	}
}

// Items -> Children
pub fn (mut this Selectbox) setup_popup(ctx &GraphicsContext, n bool) {
	mut pop := if n { &Popup{} } else { this.popup }

	if !n {
		pop.children.clear()
	}

	for item in this.items {
		mut subb := Button.new(text: item)
		subb.set_area_filled(false)
		subb.border_radius = 0
		subb.subscribe_event('mouse_up', fn [mut this] (mut e MouseEvent) {
			old_val := this.text
			this.text = e.target.text
			this.invoke_change_event(e.ctx, old_val, e.target.text)
		})
		subb.set_bounds(0, 1, this.width, this.sub_height)
		pop.add_child(subb)
	}
	ph := (this.items.len * this.sub_height) + this.items.len
	pop.set_bounds(this.x, this.y + this.height, this.width, ph)
	this.popup = pop
}

pub fn (mut this Selectbox) invoke_change_event(ctx &GraphicsContext, ov string, nv string) {
	ev := ItemChangeEvent{
		target:  this
		ctx:     ctx
		old_val: ov
		new_val: nv
	}
	for f in this.events.event_map['item_change'] {
		f(ev)
	}
}

pub fn (mut item Selectbox) draw_children(ctx &GraphicsContext) {
	mut wid := 100

	for mut sub in item.items {
		sub_size := ctx.text_width(sub + '...')
		if wid < sub_size {
			wid = sub_size
		}
	}
	if wid < item.width {
		wid = item.width
	}

	if isnil(item.popup) {
		item.setup_popup(ctx, true)
	} else {
		if item.items.len != item.popup.children.len {
			item.setup_popup(ctx, false)
		}
	}
}

pub fn (mut sb Selectbox) do_pack(ctx &GraphicsContext) {
	if sb.height == 0 {
		sb.height = min_h(ctx)
	}
	if sb.width == 0 {
		sb.width = ctx.text_width(sb.text) + 40
	}
}

pub fn (mut item Selectbox) draw(ctx &GraphicsContext) {
	if item.app == unsafe { nil } {
		item.app = ctx.win
	}

	x := item.x
	y := item.y
	mut app := item.app
	width := item.width
	height := item.height
	sizh := ctx.gg.text_height(item.text) / 2

	item.do_pack(ctx)

	mut bg := ctx.theme.button_bg_normal
	mut border := ctx.theme.button_border_normal

	midx := (x + (width / 2))
	midy := (y + (height / 2))

	// Detect Hover
	if abs(midx - app.mouse_x) < (width / 2) && abs(midy - app.mouse_y) < (height / 2) {
		bg = ctx.theme.button_bg_hover
		border = ctx.theme.button_border_hover
	}

	// Detect Click
	clicked := (abs(midx - app.click_x) < (width / 2) && abs(midy - app.click_y) < (height / 2))

	if clicked && !item.show_items {
		bg = ctx.theme.button_bg_click
		border = ctx.theme.button_border_click
		item.show_items = true
	}

	for mut subb in item.children {
		subb.height = 0
	}

	if item.show_items && item.items.len > 0 {
		bg = ctx.theme.button_bg_click
		border = ctx.theme.button_border_normal
		item.draw_children(ctx)
		if !item.popup.shown {
			item.popup.show(item, 0, item.height, ctx)
		}
	} else {
		if !isnil(item.popup) {
			if item.popup.shown {
				item.popup.shown = false
			}
		}
	}

	if item.show_items && app.click_x != -1 && app.click_y != -1 && !clicked {
		item.show_items = false
		if !isnil(item.popup) {
			mid_y := (item.popup.y + (item.popup.height / 2))
			clickedd := (abs(midx - app.click_x) < (width / 2)
				&& abs(mid_y - app.click_y) < (item.popup.height / 2))
			if !clickedd {
				item.popup.hide(ctx)
			}
		}
	}

	// Draw Button Background
	ctx.gg.draw_rect_filled(x, y, width, height, bg)

	// Draw Button Text
	ctx.draw_text(x + 5, y + (height / 2) - sizh, item.text, ctx.font, gx.TextCfg{
		size:  ctx.font_size
		color: ctx.theme.text_color
	})

	ctx.theme.button_fill_fn(x + width - 26, y, 25, height - 1, 1, bg, ctx)
	ctx.gg.draw_rect_empty(x, y, width, height, border)

	// Draw down arrow
	char_height := 3
	tx := 17

	ctx.gg.draw_triangle_filled(x + width - tx, y + (height / 2) - char_height, x + width - (tx - 5),
		y + (height / 2) + 5 - char_height, x + width - (tx - 10), y + (height / 2) - char_height,
		ctx.theme.text_color)
}
