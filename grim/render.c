#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pixman.h>

#include "buffer.h"
#include "output-layout.h"
#include "render.h"

static pixman_format_code_t get_pixman_format(enum wl_shm_format wl_fmt) {
	switch (wl_fmt) {
#if GRIM_LITTLE_ENDIAN
	case WL_SHM_FORMAT_RGB332:
		return PIXMAN_r3g3b2;
	case WL_SHM_FORMAT_BGR233:
		return PIXMAN_b2g3r3;
	case WL_SHM_FORMAT_ARGB4444:
		return PIXMAN_a4r4g4b4;
	case WL_SHM_FORMAT_XRGB4444:
		return PIXMAN_x4r4g4b4;
	case WL_SHM_FORMAT_ABGR4444:
		return PIXMAN_a4b4g4r4;
	case WL_SHM_FORMAT_XBGR4444:
		return PIXMAN_x4b4g4r4;
	case WL_SHM_FORMAT_ARGB1555:
		return PIXMAN_a1r5g5b5;
	case WL_SHM_FORMAT_XRGB1555:
		return PIXMAN_x1r5g5b5;
	case WL_SHM_FORMAT_ABGR1555:
		return PIXMAN_a1b5g5r5;
	case WL_SHM_FORMAT_XBGR1555:
		return PIXMAN_x1b5g5r5;
	case WL_SHM_FORMAT_RGB565:
		return PIXMAN_r5g6b5;
	case WL_SHM_FORMAT_BGR565:
		return PIXMAN_b5g6r5;
	case WL_SHM_FORMAT_RGB888:
		return PIXMAN_r8g8b8;
	case WL_SHM_FORMAT_BGR888:
		return PIXMAN_b8g8r8;
	case WL_SHM_FORMAT_ARGB8888:
		return PIXMAN_a8r8g8b8;
	case WL_SHM_FORMAT_XRGB8888:
		return PIXMAN_x8r8g8b8;
	case WL_SHM_FORMAT_ABGR8888:
		return PIXMAN_a8b8g8r8;
	case WL_SHM_FORMAT_XBGR8888:
		return PIXMAN_x8b8g8r8;
	case WL_SHM_FORMAT_BGRA8888:
		return PIXMAN_b8g8r8a8;
	case WL_SHM_FORMAT_BGRX8888:
		return PIXMAN_b8g8r8x8;
	case WL_SHM_FORMAT_RGBA8888:
		return PIXMAN_r8g8b8a8;
	case WL_SHM_FORMAT_RGBX8888:
		return PIXMAN_r8g8b8x8;
	case WL_SHM_FORMAT_ARGB2101010:
		return PIXMAN_a2r10g10b10;
	case WL_SHM_FORMAT_ABGR2101010:
		return PIXMAN_a2b10g10r10;
	case WL_SHM_FORMAT_XRGB2101010:
		return PIXMAN_x2r10g10b10;
	case WL_SHM_FORMAT_XBGR2101010:
		return PIXMAN_x2b10g10r10;
#else
	case WL_SHM_FORMAT_ARGB8888:
		return PIXMAN_b8g8r8a8;
	case WL_SHM_FORMAT_XRGB8888:
		return PIXMAN_b8g8r8x8;
	case WL_SHM_FORMAT_ABGR8888:
		return PIXMAN_r8g8b8a8;
	case WL_SHM_FORMAT_XBGR8888:
		return PIXMAN_r8g8b8x8;
	case WL_SHM_FORMAT_BGRA8888:
		return PIXMAN_a8r8g8b8;
	case WL_SHM_FORMAT_BGRX8888:
		return PIXMAN_x8r8g8b8;
	case WL_SHM_FORMAT_RGBA8888:
		return PIXMAN_a8b8g8r8;
	case WL_SHM_FORMAT_RGBX8888:
		return PIXMAN_x8b8g8r8;
#endif
	default:
		return 0;
	}
}

// static void compute_composite_region(const struct pixman_f_transform *out2com,
// 		int output_width, int output_height, struct grim_box *dest,
// 		bool *grid_aligned) {
// 	struct pixman_transform o2c_fixedpt;
// 	pixman_transform_from_pixman_f_transform(&o2c_fixedpt, out2com);
//
// 	pixman_fixed_t w = pixman_int_to_fixed(output_width);
// 	pixman_fixed_t h = pixman_int_to_fixed(output_height);
// 	struct pixman_vector corners[4] = {
// 		{{0, 0, pixman_fixed_1}},
// 		{{w, 0, pixman_fixed_1}},
// 		{{0, h, pixman_fixed_1}},
// 		{{w, h, pixman_fixed_1}},
// 	};
//
// 	pixman_fixed_t x_min = INT32_MAX, x_max = INT32_MIN,
// 		y_min = INT32_MAX, y_max = INT32_MIN;
// 	for (int i = 0; i < 4; i++) {
// 		pixman_transform_point(&o2c_fixedpt, &corners[i]);
// 		x_min = corners[i].vector[0] < x_min ? corners[i].vector[0] : x_min;
// 		x_max = corners[i].vector[0] > x_max ? corners[i].vector[0] : x_max;
// 		y_min = corners[i].vector[1] < y_min ? corners[i].vector[1] : y_min;
// 		y_max = corners[i].vector[1] > y_max ? corners[i].vector[1] : y_max;
// 	}
//
// 	*grid_aligned = pixman_fixed_frac(x_min) == 0 &&
// 		pixman_fixed_frac(x_max) == 0 &&
// 		pixman_fixed_frac(y_min) == 0 &&
// 		pixman_fixed_frac(y_max) == 0;
//
// 	int32_t x1 = pixman_fixed_to_int(pixman_fixed_floor(x_min));
// 	int32_t x2 = pixman_fixed_to_int(pixman_fixed_ceil(x_max));
// 	int32_t y1 = pixman_fixed_to_int(pixman_fixed_floor(y_min));
// 	int32_t y2 = pixman_fixed_to_int(pixman_fixed_ceil(y_max));
// 	*dest = (struct grim_box) {
// 		.x = x1,
// 		.y = y1,
// 		.width = x2 - x1,
// 		.height = y2 - y1
// 	};
// }

void render(struct grim_state *state) {
	// int common_width = geometry->width * scale;
	// int common_height = geometry->height * scale;
	// pixman_image_t *common_image = pixman_image_create_bits(PIXMAN_a8r8g8b8,
	// 	common_width, common_height, NULL, 0);
	// if (!common_image) {
	// 	fprintf(stderr, "failed to create image with size: %d x %d\n",
	// 		common_width, common_height);
	// 	return NULL;
	// }

	struct grim_toplevel *toplevel;
	wl_list_for_each(toplevel, &state->toplevels, link) {
		struct grim_buffer *buffer = toplevel->buffer;
		if (buffer == NULL) {
			continue;
		}

		pixman_format_code_t pixman_fmt = get_pixman_format(buffer->format);
		if (!pixman_fmt) {
			fprintf(stderr, "unsupported format %d = 0x%08x\n",
				buffer->format, buffer->format);
			return;
		}

		int toplevel_flipped_y = toplevel->toplevel_export_frame_flags &
			HYPRLAND_TOPLEVEL_EXPORT_FRAME_V1_FLAGS_Y_INVERT ? -1 : 1;

		pixman_image_t *toplevel_image = pixman_image_create_bits(
			pixman_fmt, buffer->width, buffer->height,
			buffer->data, buffer->stride);
		if (!toplevel_image) {
			fprintf(stderr, "Failed to create image\n");
			return;
		}

		pixman_f_transform_scale(toplevel_image, NULL,
			(double)1,
			(double)1 * toplevel_flipped_y);
		pixman_image_t *output_image = pixman_image_create_bits(
			PIXMAN_a8r8g8b8, buffer->width, buffer->height,
			buffer->data, buffer->stride);

    pixman_image_composite32(
        PIXMAN_OP_SRC,  // You can use different composite operators as needed.
        toplevel_image,
        NULL,
        output_image,
        0, 0, 0, 0, 0, 0, buffer->width, buffer->height
    );
    pixman_image_unref(toplevel_image);
		toplevel->image = output_image;
	}
}
