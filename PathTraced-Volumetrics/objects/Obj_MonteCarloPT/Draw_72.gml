var w = occluder_size;

surface_set_target(render_emissivity.memory);
draw_clear_alpha(c_black, 0);
	//draw_sprite_ext(Spr_SampleSceneA, 0, 0, 0, 0.5, 0.5, 0, c_white, 1.0);
	draw_set_color($FFFFFF);
	draw_circle(floor(mouse_x/2), floor(mouse_y/2), occluder_size, false);
	//draw_rectangle(floor(63)-w,floor(63)-w,floor(63)+w,floor(63)+w, false);
	//draw_point(floor(mouse_x/8), floor(mouse_y/8));
surface_reset_target();

surface_set_target(render_absorption.memory);
draw_clear_alpha(c_black, 0);
gpu_set_blendmode(bm_add);
	//draw_sprite_ext(Spr_SampleSceneB, 0, 0, 0, 0.5, 0.5, 0, c_white, 1.0);
	draw_set_color($FFFFFF);
	draw_circle(floor(mouse_x/2), floor(mouse_y/2), occluder_size, false);
	//draw_rectangle(floor(63)-w,floor(63)-w,floor(63)+w,floor(63)+w, false);
	//draw_point(floor(mouse_x/8), floor(mouse_y/8));
	//draw_set_color($101010);
	//draw_circle(127, 127, 64, false);
gpu_set_blendmode(bm_normal);
surface_reset_target();

/*
	When adding any object into either the emissive or absorption
	surfaces they need to be added using the additive blend mode.
	Otherwise you over-write the emissive or absorption properties
	of other objects and get undefined behavior.
	
	Volumetrics is also a linear process, so you cannot apply any
	emission/asborpsion properties in non-linear ways, e.g. only using
	additive/subtractive mediums.
*/