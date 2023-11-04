#ifndef _GRIM_H
#define _GRIM_H

#include <wayland-client.h>

#include "box.h"
#include "hyprland-toplevel-export-v1-client-protocol.h"
#include "xdg-output-unstable-v1-client-protocol.h"
#include "wlr-foreign-toplevel-management-unstable-v1-client-protocol.h"

enum grim_filetype {
	GRIM_FILETYPE_PNG,
	GRIM_FILETYPE_PPM,
	GRIM_FILETYPE_JPEG,
};

struct grim_state {
	struct wl_display *display;
	struct wl_registry *registry;
	struct wl_shm *shm;
	// struct zxdg_output_manager_v1 *xdg_output_manager;
	struct zwlr_foreign_toplevel_manager_v1 *foreign_toplevel_manager;
	struct hyprland_toplevel_export_manager_v1 *toplevel_export_manager;
	struct wl_list toplevels;
	size_t n_done;
};

struct grim_buffer;

struct grim_toplevel {
	struct grim_state *state;
	struct grim_buffer *buffer;
	struct zwlr_foreign_toplevel_handle_v1* handle;
	struct hyprland_toplevel_export_frame_v1 *toplevel_export_frame;
	uint32_t toplevel_export_frame_flags; // enum hyprland_toplevel_export_frame_v1_flags
	struct wl_list link;
	pixman_image_t *image;
};

#endif
