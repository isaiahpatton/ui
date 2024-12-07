module iui

import gx

// Progress bar - implements Component interface
pub struct Progressbar {
	Component_A
pub mut:
	text     string
	bind_val &f32
}

@[params]
pub struct ProgressbarConfig {
pub mut:
	val  f32
	bind ?&f32
}

// Return new Progressbar
pub fn Progressbar.new(conf ProgressbarConfig) &Progressbar {
	return &Progressbar{
		text:     conf.val.str()
		bind_val: conf.bind or { unsafe { nil } }
	}
}

pub fn (mut this Progressbar) bind_to(val &f32) {
	unsafe {
		this.bind_val = val
	}
}

pub fn (bar &Progressbar) get_val() f32 {
	if isnil(bar.bind_val) {
		return bar.text.f32()
	} else {
		return *bar.bind_val
	}
}

// Draw this component
pub fn (mut bar Progressbar) draw(ctx &GraphicsContext) {
	val := bar.get_val()
	wid := bar.width * (0.01 * val)

	// ctx.gg.draw_rect_filled(bar.x, bar.y, wid, bar.height, ctx.theme.accent_fill)
	// ctx.gg.draw_rect_empty(bar.x, bar.y, bar.width, bar.height, ctx.theme.button_border_normal)

	ctx.gg.draw_rounded_rect_filled(bar.x, bar.y, bar.width, bar.height, 4, ctx.theme.button_border_normal)
	ctx.gg.draw_rounded_rect_filled(bar.x + 1, bar.y + 1, wid - 2, bar.height - 2, 4,
		ctx.theme.accent_fill)

	c := if wid > bar.width / 2 { ctx.theme.accent_text } else { ctx.theme.text_color }

	bar.draw_text(ctx, val, c)
}

fn (bar &Progressbar) draw_text(ctx &GraphicsContext, val f32, c gx.Color) {
	text := '${val}%'
	size := ctx.gg.text_width(text) / 2
	sizh := ctx.line_height / 2

	ctx.draw_text((bar.x + (bar.width / 2)) - size, bar.y + (bar.height / 2) - sizh, text,
		ctx.font, gx.TextCfg{
		size:  ctx.font_size
		color: c
	})
}
