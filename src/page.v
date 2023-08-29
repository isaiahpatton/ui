module iui

import gg
import gx

// Page
pub struct Page {
	Component_A
pub:
	text_cfg gx.TextCfg
pub mut:
	window     &Window
	text       string
	needs_init bool
	close      &Button
	in_height  int
	top_off    int = 75
	xs         int
	line_color gx.Color = gx.rgba(0, 0, 0, 90)
}

fn draw_cfg() gx.TextCfg {
	return gx.TextCfg{
		size: 36
		color: gx.white
	}
}

[params]
pub struct PageCfg {
	title string
}

pub fn Page.new(c PageCfg) &Page {
	return page(unsafe { nil }, c.title)
}

pub fn page(app &Window, title string) &Page {
	return &Page{
		text: title
		window: app
		z_index: 500
		needs_init: true
		draw_event_fn: fn (mut win Window, mut com Component) {
			if mut com is Page {
				for mut kid in com.children {
					kid.draw_event_fn(mut win, kid)
				}
			}
		}
		text_cfg: draw_cfg()
		in_height: 300
		close: 0
	}
}

fn (this &Page) draw_bg(ctx &GraphicsContext) {
	bg := gx.rgb(51, 114, 153)
	ctx.gg.draw_rect_filled(0, 0, this.width, this.height, ctx.theme.background)
	ctx.gg.draw_rect_filled(0, 0, this.width, this.top_off, bg)
	ctx.gg.draw_rect_filled(0, this.top_off - 5, this.width, 3, this.line_color)
}

pub fn (mut this Page) draw(ctx &GraphicsContext) {
	if isnil(this.window) {
		mut win := ctx.win
		this.window = win
	}

	mut app := this.window
	ws := gg.window_size()

	this.width = ws.width
	this.height = ws.height

	this.draw_bg(ctx)

	title := this.text
	ctx.draw_text(56, 18, title, ctx.font, this.text_cfg)

	ctx.gg.set_text_cfg(gx.TextCfg{
		size: ctx.font_size
		color: ctx.theme.text_color
	})

	// Do component draw event again to fix z-index
	this.draw_event_fn(mut app, &Component(this))

	if this.needs_init {
		this.create_close_btn(mut app, true)
		this.needs_init = false
	}

	y_off := this.y + this.top_off

	if this.children.len == 2 {
		if this.children[0] is Panel || this.children[0] is ScrollView {
			// Content Pane
			if ws.width > 0 {
				this.children[0].width = ws.width
			}
			if ws.height > 5 {
				this.children[0].height = ws.height - y_off - 3
			}
		}
	}

	// this.children.sort(a.z_index < b.z_index)
	for mut com in this.children {
		com.draw_event_fn(mut app, com)
		app.draw_with_offset(mut com, 0, y_off + 2)
	}
}

pub fn (mut this Page) create_close_btn(mut app Window, ce bool) &Button {
	mut close := Button.new(text: '<')
	y := 10
	wid := this.top_off - (y * 2)
	close.set_bounds(8, -this.top_off + y, 40, wid)

	if ce {
		close.set_background(gx.rgba(230, 230, 230, 50))
		close.subscribe_event('mouse_up', fn (mut e MouseEvent) {
			e.ctx.win.components = e.ctx.win.components.filter(mut it !is Page)
		})
	}

	this.children << close
	this.close = close
	return close
}

pub fn default_page_close_fn(mut win Window, btn Button) {
	win.components = win.components.filter(mut it !is Page)
}
