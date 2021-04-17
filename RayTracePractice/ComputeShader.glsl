#version 430
layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
layout(rgba32f, binding = 0) uniform image2D img_output;

#define MAXMESH 1000

layout(std140, binding = 0) uniform MESH_IN
{
	vec3 verts[MAXMESH];
} vertices;

uniform float size;

vec3 ray_o;
vec3 ray_d;
vec4 pixel;
float dis;
vec4 color;

vec3 normalizeTri(vec3 points[3]){
	return cross(points[1]-points[0],points[2]-points[0]);
}

float triangle(vec3 points[3]){
	vec3 N = normalizeTri(points);
	float d = dot(N,points[0]);
	
	if(abs(dot(N,ray_d))<0.1f) return -1.0f;

	float t = -1*(dot(N,ray_o)+d)/dot(N,ray_d);

	if(t<0) return -1.0f;

	vec3 p = ray_o + t*ray_d;

	if(dot(N,cross(points[1]-points[0],p-points[0]))>0 &&
	   dot(N,cross(points[2]-points[1],p-points[1]))>0 &&
	   dot(N,cross(points[0]-points[2],p-points[2]))>0){
	   
	   float dist = length(ray_d*t);
	   return dist;

	}

	return -1.0f;
}

float sphere(vec3 c, float r){
	vec3 omc = ray_o-c;
	float b = dot(ray_d,omc);
	float d = dot(omc,omc) - r*r;
	float bsqmc = b*b-d;

	if(bsqmc >= 0.0){
		float t = -1*b + sqrt(bsqmc);
		float dist = length(ray_d*t);
		return dist;
	}

	return -1.0f;
}

void drawMesh(){
	float curdist = -1.0f;
	vec4 curcolor = color;

	int i = 0;
	while(i<size){
		vec3 tempv[3] = {vertices.verts[i],vertices.verts[i+1],vertices.verts[i+2]};
		float tempdist = triangle(tempv);
		if(tempdist>curdist){
			curdist = tempdist;
			curcolor = vec4(0.4,0.4,1.0,1.0);
		}
		i = i+3;
	}

	dis = curdist;
	color = curcolor;
}

void main(){
	ivec2 pixel_coords = ivec2(gl_GlobalInvocationID.xy);

	float max_x = 5.0;
	float max_y = 5.0;
	ivec2 dims = imageSize(img_output);
	float x = (float(pixel_coords.x * 2 - dims.x) / dims.x);
	float y = (float(pixel_coords.y * 2 - dims.y) / dims.y);

	pixel = vec4(abs(x),abs(y),0.0,1.0);

	ray_o = vec3(0,0,-10.0);
	ray_d = normalize(vec3(x*max_x,y*max_y,0.0)-ray_o);

	dis = -1.0f;
	color = pixel;

	drawMesh();

	pixel = color;
	
	imageStore(img_output,pixel_coords,pixel);
}