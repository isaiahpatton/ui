module iui

import gg
import gx

// Titlebox -
//	Titled border around children
pub struct Titlebox {
	Component_A
pub mut:
	text    string
	padding int = 10
}

// Return new Progressbar
pub fn title_box(text string, children []Component) &Titlebox {
	return &Titlebox{
		text: text
		children: children
	}
}

// Draw this component
pub fn (mut this Titlebox) draw(ctx &GraphicsContext) {
	mut win := ctx.win
	text_height := ctx.line_height / 2

	for mut com in this.children {
		com.draw_event_fn(mut win, com)
		y := this.y + this.padding + text_height + 5
		win.draw_with_offset(mut com, this.x + this.padding, y)
		com.after_draw_event_fn(mut win, com)

		wid := com.x + com.width + (this.padding * 2)
		if wid > this.width {
			this.width = wid
		}

		hei := com.y + com.height + (this.padding * 2) + text_height + 5
		if hei > this.height {
			this.height = hei
		}
	}

	y := this.y + text_height
	x := this.x + 16
	hei := this.height - text_height

	wid := ctx.gg.text_width(this.text)

	ctx.gg.draw_rect_empty(this.x, y, this.width, hei, ctx.theme.button_border_normal)
	ctx.gg.draw_rect_filled(x - 8, this.y, wid + 16, text_height, ctx.theme.background)
	ctx.draw_text(x, this.y, this.text, ctx.font, gx.TextCfg{
		color: ctx.theme.text_color
	})
}