#define _POSIX_C_SOURCE 200809L
#include <assert.h>
#include <errno.h>
#include <limits.h>
#include <pixman.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <wordexp.h>

#include "buffer.h"
#include "grim.h"
#include "output-layout.h"
#include "render.h"
#include "write_ppm.h"
#if HAVE_JPEG
#include "write_jpg.h"
#endif
#include "write_png.h"

static void noop () {}

static void toplevel_export_frame_handle_buffer(void *data,
		struct hyprland_toplevel_export_frame_v1 *frame, uint32_t format, uint32_t width,
		uint32_t height, uint32_t stride) {
	struct grim_toplevel *toplevel = data;

	toplevel->buffer =
		create_buffer(toplevel->state->shm, format, width, height, stride);
	if (toplevel->buffer == NULL) {
		fprintf(stderr, "failed to create buffer\n");
		exit(EXIT_FAILURE);
	}

	hyprland_toplevel_export_frame_v1_copy(frame, toplevel->buffer->wl_buffer, 1);
}

static void toplevel_export_frame_handle_flags(void *data,
		struct hyprland_toplevel_export_frame_v1 *frame, uint32_t flags) {
	struct grim_toplevel *toplevel = data;
	toplevel->toplevel_export_frame_flags = flags;
}

static void toplevel_export_frame_handle_ready(void *data,
		struct hyprland_toplevel_export_frame_v1 *frame, uint32_t tv_sec_hi,
		uint32_t tv_sec_lo, uint32_t tv_nsec) {
	struct grim_toplevel *toplevel = data;
	++toplevel->state->n_done;
}

static void toplevel_export_frame_handle_failed(void *data,
		struct hyprland_toplevel_export_frame_v1 *frame) {
	struct grim_toplevel *toplevel = data;
	fprintf(stderr, "failed to copy toplevel %p\n", (void*)toplevel);
	exit(EXIT_FAILURE);
}

static const struct hyprland_toplevel_export_frame_v1_listener toplevel_export_frame_listener = {
	.buffer = toplevel_export_frame_handle_buffer,
	.flags = toplevel_export_frame_handle_flags,
	.ready = toplevel_export_frame_handle_ready,
	.failed = toplevel_export_frame_handle_failed,
	.damage = noop,
	.linux_dmabuf = noop,
	.buffer_done = noop,
};

static void toplevel_manager_handle_toplevel (void *data, struct zwlr_foreign_toplevel_manager_v1 *manager,
		struct zwlr_foreign_toplevel_handle_v1 *handle)
{
	  struct grim_state *state = data;
		struct grim_toplevel *toplevel = calloc(1, sizeof(struct grim_toplevel));
		toplevel->state = state;
		toplevel->handle = handle;
		wl_list_insert(&state->toplevels, &toplevel->link);

		fprintf(stderr, "TOP");
	// struct Toplevel *toplevel = calloc(1, sizeof(struct Toplevel));
	// if ( toplevel == NULL )
	// {
	// 	fputs("ERROR: Failed to allocate.\n", stderr);
	// 	return;
	// }
	//
	// static uint32_t i = 0;
	//
	// toplevel->handle     = handle;
	// toplevel->i          = i++;
	// toplevel->title      = NULL;
	// toplevel->app_id     = NULL;
	// toplevel->maximized  = false;
	// toplevel->minimized  = false;
	// toplevel->activated  = false;
	// toplevel->fullscreen = false;
	// toplevel->output     = false;
	//
	// list_init(&toplevel->outputs, 1);
	//
	// zwlr_foreign_toplevel_handle_v1_add_listener(handle, &handle_listener, toplevel);
}

static const struct zwlr_foreign_toplevel_manager_v1_listener toplevel_manager_listener = {
	.toplevel = toplevel_manager_handle_toplevel,
	.finished = noop,
};


// static void xdg_output_handle_logical_position(void *data,
// 		struct zxdg_output_v1 *xdg_output, int32_t x, int32_t y) {
// 	struct grim_output *output = data;
//
// 	output->logical_geometry.x = x;
// 	output->logical_geometry.y = y;
// }
//
// static void xdg_output_handle_logical_size(void *data,
// 		struct zxdg_output_v1 *xdg_output, int32_t width, int32_t height) {
// 	struct grim_output *output = data;
//
// 	output->logical_geometry.width = width;
// 	output->logical_geometry.height = height;
// }
//
// static void xdg_output_handle_done(void *data,
// 		struct zxdg_output_v1 *xdg_output) {
// 	struct grim_output *output = data;
//
// 	// Guess the output scale from the logical size
// 	int32_t width = output->geometry.width;
// 	int32_t height = output->geometry.height;
// 	apply_output_transform(output->transform, &width, &height);
// 	output->logical_scale = (double)width / output->logical_geometry.width;
// }
//
// static void xdg_output_handle_name(void *data,
// 		struct zxdg_output_v1 *xdg_output, const char *name) {
// 	struct grim_output *output = data;
// 	output->name = strdup(name);
// }
//
// static void xdg_output_handle_description(void *data,
// 		struct zxdg_output_v1 *xdg_output, const char *name) {
// 	// No-op
// }
//
// static const struct zxdg_output_v1_listener xdg_output_listener = {
// 	.logical_position = xdg_output_handle_logical_position,
// 	.logical_size = xdg_output_handle_logical_size,
// 	.done = xdg_output_handle_done,
// 	.name = xdg_output_handle_name,
// 	.description = xdg_output_handle_description,
// };
//
//
// static void output_handle_geometry(void *data, struct wl_output *wl_output,
// 		int32_t x, int32_t y, int32_t physical_width, int32_t physical_height,
// 		int32_t subpixel, const char *make, const char *model,
// 		int32_t transform) {
// 	struct grim_output *output = data;
//
// 	output->geometry.x = x;
// 	output->geometry.y = y;
// 	output->transform = transform;
// }
//
// static void output_handle_mode(void *data, struct wl_output *wl_output,
// 		uint32_t flags, int32_t width, int32_t height, int32_t refresh) {
// 	struct grim_output *output = data;
//
// 	if ((flags & WL_OUTPUT_MODE_CURRENT) != 0) {
// 		output->geometry.width = width;
// 		output->geometry.height = height;
// 	}
// }
//
// static void output_handle_done(void *data, struct wl_output *wl_output) {
// 	// No-op
// }
//
// static void output_handle_scale(void *data, struct wl_output *wl_output,
// 		int32_t factor) {
// 	struct grim_output *output = data;
// 	output->scale = factor;
// }
//
// static const struct wl_output_listener output_listener = {
// 	.geometry = output_handle_geometry,
// 	.mode = output_handle_mode,
// 	.done = output_handle_done,
// 	.scale = output_handle_scale,
// };


static void handle_global(void *data, struct wl_registry *registry,
		uint32_t name, const char *interface, uint32_t version) {
	struct grim_state *state = data;

	if (strcmp(interface, wl_shm_interface.name) == 0) {
		state->shm = wl_registry_bind(registry, name, &wl_shm_interface, 1);
	} else if (strcmp(interface, zwlr_foreign_toplevel_manager_v1_interface.name) == 0) {
		uint32_t bind_version = (version > 3) ? 3 : version;
		state->foreign_toplevel_manager = wl_registry_bind(registry, name,
			&zwlr_foreign_toplevel_manager_v1_interface, bind_version);
	} else if (strcmp(interface, hyprland_toplevel_export_manager_v1_interface.name) == 0) {
		state->toplevel_export_manager = wl_registry_bind(registry, name,
			&hyprland_toplevel_export_manager_v1_interface, 2);
	}
}

static void handle_global_remove(void *data, struct wl_registry *registry,
		uint32_t name) {
	// who cares
}

static const struct wl_registry_listener registry_listener = {
	.global = handle_global,
	.global_remove = handle_global_remove,
};

static bool default_filename(char *filename, size_t n, int filetype) {
	time_t time_epoch = time(NULL);
	struct tm *time = localtime(&time_epoch);
	if (time == NULL) {
		perror("localtime");
		return false;
	}

	char *format_str;
	const char *ext = NULL;
	switch (filetype) {
	case GRIM_FILETYPE_PNG:
		ext = "png";
		break;
	case GRIM_FILETYPE_PPM:
		ext = "ppm";
		break;
	case GRIM_FILETYPE_JPEG:
#if HAVE_JPEG
		ext = "jpeg";
		break;
#else
		abort();
#endif
	}
	assert(ext != NULL);
	char tmpstr[32];
	sprintf(tmpstr, "%%Y%%m%%d_%%Hh%%Mm%%Ss_grim.%s", ext);
	format_str = tmpstr;
	if (strftime(filename, n, format_str, time) == 0) {
		fprintf(stderr, "failed to format datetime with strftime(3)\n");
		return false;
	}
	return true;
}

static bool path_exists(const char *path) {
	return path && access(path, R_OK) != -1;
}

char *get_xdg_pictures_dir(void) {
	const char *home_dir = getenv("HOME");
	if (home_dir == NULL) {
		return NULL;
	}

	char *config_file;
	const char user_dirs_file[] = "user-dirs.dirs";
	const char config_home_fallback[] = ".config";
	const char *config_home = getenv("XDG_CONFIG_HOME");
	if (config_home == NULL || config_home[0] == 0) {
		size_t size = strlen(home_dir) + strlen("/") +
				strlen(config_home_fallback) + strlen("/") + strlen(user_dirs_file) + 1;
		config_file = malloc(size);
		if (config_file == NULL) {
			return NULL;
		}
		snprintf(config_file, size, "%s/%s/%s", home_dir, config_home_fallback, user_dirs_file);
	} else {
		size_t size = strlen(config_home) + strlen("/") + strlen(user_dirs_file) + 1;
		config_file = malloc(size);
		if (config_file == NULL) {
			return NULL;
		}
		snprintf(config_file, size, "%s/%s", config_home, user_dirs_file);
	}

	FILE *file = fopen(config_file, "r");
	free(config_file);
	if (file == NULL) {
		return NULL;
	}

	char *line = NULL;
	size_t line_size = 0;
	ssize_t nread;
	char *pictures_dir = NULL;
	while ((nread = getline(&line, &line_size, file)) != -1) {
		if (nread > 0 && line[nread - 1] == '\n') {
			line[nread - 1] = '\0';
		}

		if (strlen(line) == 0 || line[0] == '#') {
			continue;
		}

		size_t i = 0;
		while (line[i] == ' ') {
			i++;
		}
		const char prefix[] = "XDG_PICTURES_DIR=";
		if (strncmp(&line[i], prefix, strlen(prefix)) == 0) {
			const char *line_remaining = &line[i] + strlen(prefix);
			wordexp_t p;
			if (wordexp(line_remaining, &p, WRDE_UNDEF) == 0) {
				free(pictures_dir);
				pictures_dir = strdup(p.we_wordv[0]);
				wordfree(&p);
			}
		}
	}
	free(line);
	fclose(file);
	return pictures_dir;
}

char *get_output_dir(void) {
	const char *grim_default_dir = getenv("GRIM_DEFAULT_DIR");
	if (path_exists(grim_default_dir)) {
		return strdup(grim_default_dir);
	}

	char *xdg_fallback_dir = get_xdg_pictures_dir();
	if (path_exists(xdg_fallback_dir)) {
		return xdg_fallback_dir;
	} else {
		free(xdg_fallback_dir);
	}

	return strdup(".");
}

static const char usage[] =
	"Usage: grim [options...] [output-file]\n"
	"\n"
	"  -h              Show help message and quit.\n"
	"  -s <factor>     Set the output image scale factor. Defaults to the\n"
	"                  greatest output scale factor.\n"
	"  -g <geometry>   Set the region to capture.\n"
	"  -t png|ppm|jpeg Set the output filetype. Defaults to png.\n"
	"  -q <quality>    Set the JPEG filetype quality 0-100. Defaults to 80.\n"
	"  -l <level>      Set the PNG filetype compression level 0-9. Defaults to 6.\n"
	"  -o <output>     Set the output name to capture.\n"
	"  -c              Include cursors in the screenshot.\n";

int main(int argc, char *argv[]) {
	double scale = 1.0;
	bool use_greatest_scale = true;
	// struct grim_box *geometry = NULL;
	// char *geometry_output = NULL;
	enum grim_filetype output_filetype = GRIM_FILETYPE_PNG;
	int jpeg_quality = 80;
	int png_level = 6; // current default png/zlib compression level
	bool with_cursor = false;
	int opt;
	while ((opt = getopt(argc, argv, "hs:g:t:q:l:o:c")) != -1) {
		switch (opt) {
		case 'h':
			printf("%s", usage);
			return EXIT_SUCCESS;
		case 's':
			use_greatest_scale = false;
			scale = strtod(optarg, NULL);
			break;
		// case 'g':;
		// 	char *geometry_str = NULL;
		// 	if (strcmp(optarg, "-") == 0) {
		// 		size_t n = 0;
		// 		ssize_t nread = getline(&geometry_str, &n, stdin);
		// 		if (nread < 0) {
		// 			free(geometry_str);
		// 			fprintf(stderr, "failed to read a line from stdin\n");
		// 			return EXIT_FAILURE;
		// 		}
		//
		// 		if (nread > 0 && geometry_str[nread - 1] == '\n') {
		// 			geometry_str[nread - 1] = '\0';
		// 		}
		// 	} else {
		// 		geometry_str = strdup(optarg);
		// 	}
		//
		// 	free(geometry);
		// 	geometry = calloc(1, sizeof(struct grim_box));
		// 	if (!parse_box(geometry, geometry_str)) {
		// 		fprintf(stderr, "invalid geometry\n");
		// 		return EXIT_FAILURE;
		// 	}
		//
		// 	free(geometry_str);
		// 	break;
		case 't':
			if (strcmp(optarg, "png") == 0) {
				output_filetype = GRIM_FILETYPE_PNG;
			} else if (strcmp(optarg, "ppm") == 0) {
				output_filetype = GRIM_FILETYPE_PPM;
			} else if (strcmp(optarg, "jpeg") == 0) {
#if HAVE_JPEG
				output_filetype = GRIM_FILETYPE_JPEG;
#else
				fprintf(stderr, "jpeg support disabled\n");
				return EXIT_FAILURE;
#endif
			} else {
				fprintf(stderr, "invalid filetype\n");
				return EXIT_FAILURE;
			}
			break;
		case 'q':
			if (output_filetype != GRIM_FILETYPE_JPEG) {
				fprintf(stderr, "quality is used only for jpeg files\n");
				return EXIT_FAILURE;
			} else {
				char *endptr = NULL;
				errno = 0;
				jpeg_quality = strtol(optarg, &endptr, 10);
				if (*endptr != '\0' || errno) {
					fprintf(stderr, "quality must be a integer\n");
					return EXIT_FAILURE;
				}
				if (jpeg_quality < 0 || jpeg_quality > 100) {
					fprintf(stderr, "quality valid values are between 0-100\n");
					return EXIT_FAILURE;
				}
			}
			break;
		case 'l':
			if (output_filetype != GRIM_FILETYPE_PNG) {
				fprintf(stderr, "compression level is used only for png files\n");
				return EXIT_FAILURE;
			} else {
				char *endptr = NULL;
				errno = 0;
				png_level = strtol(optarg, &endptr, 10);
				if (*endptr != '\0' || errno) {
					fprintf(stderr, "level must be a integer\n");
					return EXIT_FAILURE;
				}
				if (png_level < 0 || png_level > 9) {
					fprintf(stderr, "compression level valid values are between 0-9\n");
					return EXIT_FAILURE;
				}
			}
			break;
		// case 'o':
		// 	free(geometry_output);
		// 	geometry_output = strdup(optarg);
		// 	break;
		case 'c':
			with_cursor = true;
			break;
		default:
			return EXIT_FAILURE;
		}
	}

	const char *output_filename;
	char *output_filepath;
	char tmp[64];
	if (optind >= argc) {
		if (!default_filename(tmp, sizeof(tmp), output_filetype)) {
			fprintf(stderr, "failed to generate default filename\n");
			return EXIT_FAILURE;
		}
		output_filename = tmp;

		char *output_dir = get_output_dir();
		int len = snprintf(NULL, 0, "%s/%s", output_dir, output_filename);
		if (len < 0) {
			perror("snprintf failed");
			return EXIT_FAILURE;
		}
		output_filepath = malloc(len + 1);
		snprintf(output_filepath, len + 1, "%s/%s", output_dir, output_filename);
		free(output_dir);
	} else if (optind < argc - 1) {
		printf("%s", usage);
		return EXIT_FAILURE;
	} else {
		output_filename = argv[optind];
		output_filepath = strdup(output_filename);
	}

	struct grim_state state = {0};
	wl_list_init(&state.toplevels);

	state.display = wl_display_connect(NULL);
	if (state.display == NULL) {
		fprintf(stderr, "failed to create display\n");
		return EXIT_FAILURE;
	}

	state.registry = wl_display_get_registry(state.display);
	wl_registry_add_listener(state.registry, &registry_listener, &state);

	wl_display_roundtrip(state.display);

	if (state.shm == NULL) {
		fprintf(stderr, "compositor doesn't support wl_shm\n");
		return EXIT_FAILURE;
	}
	// if (wl_list_empty(&state.outputs)) {
	// 	fprintf(stderr, "no wl_output\n");
	// 	return EXIT_FAILURE;
	// }

	// if (state.xdg_output_manager != NULL) {
	// 	struct grim_output *output;
	// 	wl_list_for_each(output, &state.outputs, link) {
	// 		output->xdg_output = zxdg_output_manager_v1_get_xdg_output(
	// 			state.xdg_output_manager, output->wl_output);
	// 		zxdg_output_v1_add_listener(output->xdg_output,
	// 			&xdg_output_listener, output);
	// 	}
	//
	// 	wl_display_roundtrip(state.display);
	// } else {
	// 	fprintf(stderr, "warning: zxdg_output_manager_v1 isn't available, "
	// 		"guessing the output layout\n");
	//
	// 	struct grim_output *output;
	// 	wl_list_for_each(output, &state.outputs, link) {
	// 		guess_output_logical_geometry(output);
	// 	}
	// }

	if (state.foreign_toplevel_manager == NULL) {
		fprintf(stderr, "compositor doesn't support zwlr_foreign_toplevel_manager_v1\n");
		return EXIT_FAILURE;
	}

	zwlr_foreign_toplevel_manager_v1_add_listener(state.foreign_toplevel_manager,
		&toplevel_manager_listener, &state);

	// wl_display_roundtrip(state.display);

	while (wl_list_empty(&state.toplevels) && wl_display_dispatch(state.display) != -1);
	fprintf(stderr, "DAMN");

	if (state.toplevel_export_manager == NULL) {
		fprintf(stderr, "compositor doesn't support hyprland-toplevel-export-v1\n");
		return EXIT_FAILURE;
	}

	// if (geometry_output != NULL) {
	// 	struct grim_output *output;
	// 	wl_list_for_each(output, &state.outputs, link) {
	// 		if (output->name != NULL &&
	// 				strcmp(output->name, geometry_output) == 0) {
	// 			geometry = calloc(1, sizeof(struct grim_box));
	// 			memcpy(geometry, &output->logical_geometry,
	// 				sizeof(struct grim_box));
	// 		}
	// 	}
	//
	// 	if (geometry == NULL) {
	// 		fprintf(stderr, "unknown output '%s'\n", geometry_output);
	// 		return EXIT_FAILURE;
	// 	}
	// }

	size_t n_pending = 0;
	struct grim_toplevel *toplevel;
	wl_list_for_each(toplevel, &state.toplevels, link) {
		toplevel->toplevel_export_frame = hyprland_toplevel_export_manager_v1_capture_toplevel_with_wlr_toplevel_handle(
			state.toplevel_export_manager, 1, toplevel->handle);
		hyprland_toplevel_export_frame_v1_add_listener(toplevel->toplevel_export_frame,
			&toplevel_export_frame_listener, toplevel);
		++n_pending;
	}


	bool done = false;
	while (!done && wl_display_dispatch(state.display) != -1) {
		done = (state.n_done == n_pending);
	}
	if (!done) {
		fprintf(stderr, "failed to screenshoot all toplevels\n");
		return EXIT_FAILURE;
	}

	// if (geometry == NULL) {
	// 	geometry = calloc(1, sizeof(struct grim_box));
	// 	get_output_layout_extents(&state, geometry);
	// }

	render(&state);
	struct grim_toplevel *toplevel_tmpp = wl_container_of(state.toplevels.next, toplevel_tmpp, link);
	pixman_image_t *image = toplevel_tmpp->image;

	if (image == NULL) {
		return EXIT_FAILURE;
	}

	FILE *file;
	if (strcmp(output_filename, "-") == 0) {
		file = stdout;
	} else {
		file = fopen(output_filepath, "w");
		if (!file) {
			fprintf(stderr, "Failed to open file '%s' for writing: %s\n",
				output_filepath, strerror(errno));
			return EXIT_FAILURE;
		}
	}

	int ret = 0;
	switch (output_filetype) {
	case GRIM_FILETYPE_PPM:
		ret = write_to_ppm_stream(image, file);
		break;
	case GRIM_FILETYPE_PNG:
		ret = write_to_png_stream(image, file, png_level);
		break;
	case GRIM_FILETYPE_JPEG:
#if HAVE_JPEG
		ret = write_to_jpeg_stream(image, file, jpeg_quality);
		break;
#else
		abort();
#endif
	}
	if (ret == -1) {
		// Error messages will be printed at the source
		return EXIT_FAILURE;
	}

	if (strcmp(output_filename, "-") != 0) {
		fclose(file);
	}

	free(output_filepath);
	pixman_image_unref(image);
	struct grim_toplevel *toplevel_tmp;
	wl_list_for_each_safe(toplevel, toplevel_tmp, &state.toplevels, link) {
		wl_list_remove(&toplevel->link);
		if (toplevel->toplevel_export_frame != NULL) {
			hyprland_toplevel_export_frame_v1_destroy(toplevel->toplevel_export_frame);
		}
		destroy_buffer(toplevel->buffer);
		free(toplevel);
	}
	hyprland_toplevel_export_manager_v1_destroy(state.toplevel_export_manager);
	// if (state.xdg_output_manager != NULL) {
	// 	zxdg_output_manager_v1_destroy(state.xdg_output_manager);
	// }
	wl_shm_destroy(state.shm);
	wl_registry_destroy(state.registry);
	wl_display_disconnect(state.display);
	// free(geometry);
	// free(geometry_output);
	return EXIT_SUCCESS;
}
