#version 300 es
precision highp float;

uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_mouse;

#define S(a,b,x)smoothstep(a,b,x)

out vec4 col;

const mat2 m=mat2(.80,.60,-.60,.80);

// https://www.shadertoy.com/view/XlGcRh
uvec3 pcg3d(uvec3 v){
	
	v=v*1664525u+1013904223u;
	
	v.x+=v.y*v.z;
	v.y+=v.z*v.x;
	v.z+=v.x*v.y;
	
	v^=v>>16u;
	
	v.x+=v.y*v.z;
	v.y+=v.z*v.x;
	v.z+=v.x*v.y;
	
	return v;
}

// range is 0..1
vec3 pcg2d3f(uvec2 v)
{
	return vec3(pcg3d(uvec3(v,0)))/float(0xFFFFFFFFu);
}

vec3 map(vec2 uv,vec2 mouse)
{
	uv*=4.+20.*mouse.x;
	
	uvec2 uvi=uvec2(floor(uv));
	vec2 uvf=-.5+fract(uv);
	
	vec3 col=vec3(0.);
	
	float mdist=100.;
	
	for(int i=-1;i<=1;i++)
	{
		for(int j=-1;j<=1;j++)
		{
			uvec2 cell=uvec2(i,j);
			vec3 rng=pcg2d3f(cell+uvi);
			
			vec3 ch=.8*mouse.y*rng;
			
			// start at uvf, move to cell, add the rng offset,
			// check that len
			float dist=length(-vec3(cell,.0)+vec3(uvf,0.)+ch);
			
			if(dist<mdist){
				
				mdist=dist;
				col=rng;
			}
		}
		
	}
	
	float d=length(mdist);
	return(pow(1.-d,2.)*col);
}

void main()
{
	vec2 r=u_resolution;
	
	vec2 uv=gl_FragCoord.xy/r;
	// correct aspect ratio
	uv.x*=r.x/r.y;
	vec2 mouse=u_mouse/r;
	
	vec3 rgb=map(uv,mouse);
	rgb=pow(rgb,vec3(.4545));
	
	col=vec4(rgb,1.);
}