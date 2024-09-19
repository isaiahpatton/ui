module main

import iui as ui
import browser.webview
import os

@[console]
fn main() {
	println('Browser - Alpha Test')

	mut win := ui.window(ui.get_system_theme(), 'Browser', 800, 600)
	mut bar := ui.menubar(win, win.theme)

	help_menu := ui.menu_item(
		text:     'Help'
		children: [
			ui.menu_item(
				text:           'About Browser'
				click_event_fn: about_click
			),
			ui.menu_item(
				text: 'About iUI'
			),
		]
	)

	links_menu := ui.menu_item(
		text:     'Links'
		children: [
			ui.menu_item(
				text:           'Home'
				click_event_fn: fn (mut win ui.Window, item ui.MenuItem) {
					res_path := os.resource_abs_path('test.html')
					load_url(mut win, 'file://' + res_path)
				}
			),
			ui.menu_item(
				text:           'google.com'
				click_event_fn: load_url_from_menu
			),
		]
	)

	bar.add_child(links_menu)
	bar.add_child(help_menu)

	win.bar = bar

	mut tb := ui.tabbox(win)
	tb.set_id(mut win, 'tabbar')
	tb.set_bounds(0, 30, 0, 0)
	tb.draw_event_fn = tabs_draw
	win.add_child(tb)

	create_tab(mut win, mut tb)

	win.gg.run()
}

fn load_url_from_menu(mut win ui.Window, item ui.MenuItem) {
	url := if item.text.contains('://') { item.text } else { 'http://' + item.text }

	load_url(mut win, url)
}

fn load_url(mut win ui.Window, url string) {
	webview.load_url(mut win, url)
}

// Make menu bar look like url bar.
fn menu_bar_status_theme(cur ui.Theme) ui.Theme {
	return ui.Theme{
		...cur
		menubar_background: cur.button_bg_normal
		menubar_border:     cur.button_bg_normal
	}
}

// Create tab
fn create_tab(mut win ui.Window, mut tb ui.Tabbox) {
	mut lbl := ui.label(win, 'Hello world!')

	lbl.pack()

	menubar_has_tab_color := menu_bar_status_theme(win.theme)

	mut bar := ui.menubar(win, menubar_has_tab_color)

	// bar.set_bounds(0, 25, 100, 60)
	bar.draw_event_fn = fn (mut win ui.Window, mut com ui.Component) {
		com.height = 60
	}

	// Back Button
	mut back := ui.menuitem('<')
	back.width = 30
	back.no_paint_bg = true
	bar.add_child(back)

	// Forward Buttom
	mut forward := ui.menuitem('>')
	forward.width = 30
	forward.no_paint_bg = true
	bar.add_child(forward)

	res_path := os.resource_abs_path('test.html')
	default_page_url := 'file://' + res_path

	mut urlbar := ui.text_field(text: default_page_url)
	urlbar.z_index = 5
	urlbar.set_id(mut win, 'browser_url_bar')
	urlbar.set_bounds(140, 0, 600, 25)
	urlbar.before_txtc_event_fn = before_txt_change

	tb.add_child('Test Tab', lbl)
	tb.add_child('Test Tab', bar)
	tb.add_child('Test Tab', urlbar)

	mut status := ui.menubar(win, menubar_has_tab_color)
	status.z_index = 20
	status.draw_event_fn = status_bar_draw

	mut item := ui.menu_item(text: ' ')
	item.no_paint_bg = true
	item.draw_event_fn = status_item_draw
	status.add_child(item)

	tb.add_child('Test Tab', status)

	set_status(mut win, 'Loading...')

	if os.exists(res_path) {
		load_url(mut win, default_page_url)
	} else {
		load_url(mut win, 'http://google.com')
	}

	// load_url(mut win, 'http://frogfind.com')
}

fn set_status(mut win ui.Window, text string) {
	win.extra_map['browser-status'] = text
}

fn status_item_draw(mut win ui.Window, com &ui.Component) {
	mut this := *com
	this.text = win.extra_map['browser-status']
	this.width = ui.text_width(win, this.text)
}

fn before_txt_change(mut win ui.Window, tb ui.TextField) bool {
	mut is_enter := tb.last_letter == 'enter'

	if is_enter {
		url := tb.text

		if url.starts_with('http') || url.starts_with('file') {
			load_url(mut win, tb.text)
		} else {
			load_url(mut win, 'http://' + tb.text)
		}
		return true
	}
	return false
}

fn box_draw_fn(mut win ui.Window, com &ui.Component) {
	size := win.gg.window_size()
	mut this := *com
	this.width = size.width

	if this.height > 40 {
		this.height = size.height
	}
}

fn width_draw_fn(mut win ui.Window, com &ui.Component) {
	size := win.gg.window_size()
	mut this := *com
	this.width = size.width
	if this.height > 40 {
		this.height = size.height - 102
	}
}

fn status_bar_draw(mut win ui.Window, com &ui.Component) {
	size := win.gg.window_size()
	mut this := *com
	this.y = (size.height - 25) - 30 - 25
}

fn add_child(mut box ui.Component, child &ui.Component) {
	if mut box is ui.VBox {
		box.add_child(child)
	}
	if mut box is ui.HBox {
		box.add_child(child)
	}
}

fn tabs_draw(mut win ui.Window, com &ui.Component) {
	mut this := *com
	if mut this is ui.Tabbox {
		size := win.gg.window_size()
		this.width = size.width
		this.height = size.height - 30
	}
}

fn about_click(mut win ui.Window, com ui.MenuItem) {
	mut about := ui.modal(win, 'About Browser')
	about.in_height = 300
	about.in_width = 420

	mut title := ui.label(win, 'Browser')
	title.set_pos(40, 8)
	title.set_config(16, false, true)
	title.pack()
	about.add_child(title)

	mut lbl := ui.label(win,
		'Version 0.1-alpha\n\nBrowser is a simple web browser made in\nthe V Programming Language' +
		'\n\nThis program is free software licensed under\nthe GNU General Public License v2.\n\nIcons by Icons8')
	lbl.set_pos(40, 80)
	about.add_child(lbl)

	mut copy := ui.label(win, 'Copyright © 2021-2022 Isaiah.')
	copy.set_pos(40, 250)
	copy.set_config(12, true, false)
	about.add_child(copy)

	win.add_child(about)
}
