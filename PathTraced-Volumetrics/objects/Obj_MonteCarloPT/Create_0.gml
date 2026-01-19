/*
	Simple Monte-Carlo Path Tracer:
		render_size : width,height of the renderer
		render_rays : number of rays to cast per rendered pixel
*/
surface_depth_disable(true);
game_set_speed(144 * 8, gamespeed_fps);

occluder_size = 16;
render_size = 256;
render_rays = 128;

render_surflist = ds_list_create();
render_world = surface_build(render_size, render_size, surface_rgba8unorm, render_surflist);
render_fluence = surface_build(render_size, render_size, surface_rgba8unorm, render_surflist);

render_emissivity = surface_build(render_size, render_size, surface_rgba8unorm, render_surflist);
render_absorption = surface_build(render_size, render_size, surface_rgba8unorm, render_surflist);

montecarlopt_u_Shader = Shd_MonteCarloPT;
montecarlopt_u_Emissivity = texture(montecarlopt_u_Shader, "emissivity");
montecarlopt_u_Absorption = texture(montecarlopt_u_Shader, "absorption");
montecarlopt_u_BlueNoise = texture(montecarlopt_u_Shader, "noise");
montecarlopt_u_WorldExtent = uniform(montecarlopt_u_Shader, "worldExt");
montecarlopt_u_RayCount  = uniform(montecarlopt_u_Shader, "rayCount");