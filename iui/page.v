module iui

import gg
import gx

// Page - Full Page Alternative to Modal
//
// Style Guides:
// 	https://w3schools.com/w3css/w3css_color_generator.asp
//  https://w3schools.com/w3css/w3css_color_schemes.asp
//  Colorhex: #337299
//
struct Page {
	Component_A
pub mut:
	window     &Window
	text       string
	needs_init bool
	close      &Button
	in_height  int
	top_off    int = 78
	xs         int
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
		in_height: 300
		close: 0
	}
}

pub fn (mut this Page) draw(ctx &GraphicsContext) {
	mut app := this.window
	ws := gg.window_size()

	this.width = ws.width
	this.height = ws.height

	bg := gx.rgb(51, 114, 153)
	app.gg.draw_rect_filled(0, 0, this.width, this.height, ctx.theme.background)
	app.gg.draw_rect_filled(0, 0, this.width, this.height, gx.rgba(bg.r, bg.g, bg.b, 20))
	app.gg.draw_rect_filled(0, 0, this.width, 78, bg)
	app.gg.draw_rect_filled(0, 0, this.width, 24, gx.rgba(0, 0, 0, 90))

	title := this.text
	app.gg.draw_text(56, 39, title, gx.TextCfg{
		size: 24
		color: gx.white
	})

	// Do component draw event again to fix z-index
	this.draw_event_fn(mut app, &Component(this))

	if this.needs_init {
		this.create_close_btn(mut app, true)
		this.needs_init = false
	}

	y_off := this.y + this.top_off
	for mut com in this.children {
		com.draw_event_fn(mut app, com)
		app.draw_with_offset(mut com, 0, y_off + 2)
	}
}

pub fn (mut this Page) create_close_btn(mut app Window, ce bool) &Button {
	mut close := button(app, '<')
	close.x = 8
	close.y = (-78) + 28
	close.width = 40
	close.height = 42

	if ce {
		close.set_click(default_page_close_fn)
	}

	ref := &close
	this.children << ref
	this.close = ref
	return ref
}

pub fn default_page_close_fn(mut win Window, btn Button) {
	win.components = win.components.filter(mut it !is Page)
}
