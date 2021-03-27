#version 430
layout(local_size_x = 1, local_size_y = 1) in;
layout(rgba32f, binding = 0) uniform image2D img_output;

vec3 ray_o;
vec3 ray_d;
vec4 pixel;

void sphere(vec3 c, float r, vec4 color){
	vec3 omc = ray_o-c;
	float b = dot(ray_d,omc);
	float d = dot(omc,omc) - r*r;
	float bsqmc = b*b-d;

	if(bsqmc >= 0.0) pixel = color;
}

void main(){
	pixel = vec4(0.5,0.3,0.4,1);
	ivec2 pixel_coords = ivec2(gl_GlobalInvocationID.xy);

	float max_x = 5.0;
	float max_y = 5.0;
	ivec2 dims = imageSize(img_output);
	float x = float(pixel_coords.x * 2 - dims.x) / dims.x;
	float y = float(pixel_coords.y * 2 - dims.y) / dims.y;
	ray_o = vec3(x*max_x, y*max_y, 0.0);
	ray_d = vec3(0.0,0.0,-1.0);

	vec3 sphere_c = vec3(0.0,0.0,-10.0);
	float sphere_r = 1.0;

	sphere(vec3(1.0,1.0,-10.0),1.0,vec4(0.0,1.0,0.0,1.0));
	sphere(sphere_c,sphere_r,vec4(1.0,0.0,0.0,1.0));
	
	imageStore(img_output,pixel_coords,pixel);
}