occluder_size += (mouse_wheel_up() - mouse_wheel_down()) * 1;
occluder_size = clamp(occluder_size, 1, 128);