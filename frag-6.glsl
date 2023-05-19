#version 300 es
precision highp float;

uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_mouse;

#define S(a,b,x)smoothstep(a,b,x)
#define sn(r)(r*sin(u_time))
#define cs(r)(r*cos(u_time))

out vec4 col;

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

vec3 map(vec2 uv,vec2 mouse,float intensity,float t)
{
	// vec2 m=-uv+mouse;
	uv*=4.;
	
	uvec2 uvi=uvec2(floor(uv));
	vec2 uvf=-.5+fract(uv);
	
	vec3 col=vec3(0.);
	
	for(int i=-1;i<=1;i++)
	{
		for(int j=-1;j<=1;j++)
		{
			uvec2 cell=uvec2(i,j);
			vec3 rng=pcg2d3f(cell+uvi);
			
			vec3 ch=.5*((.5+.5*sin(rng*t*.5))-.5);
			
			float dist=length(-vec3(uvf,0.)+vec3(cell,0.)+ch);
			
			float glow=pow(intensity/dist*.5,8.)*.152;
			
			col+=rng*glow;
		}
		
	}
	
	return 1.-exp(-col);
}

void main()
{
	vec2 r=u_resolution;
	
	vec2 uv=gl_FragCoord.xy/r;
	// correct aspect ratio
	uv.x*=r.x/r.y;
	
	// make mouse agree on coordinate system
	vec2 mouse=u_mouse/r*2.-1.;
	mouse.x*=r.x/r.y;
	
	float intensity=.2;
	
	vec3 rgb=map(uv,mouse,.2,u_time);
	rgb+=map(uv*1.2,mouse,.1,u_time*1.3);
	rgb+=map(uv*2.2,mouse,.08,u_time*2.3);
	rgb+=map(uv*3.2,mouse,.08,u_time*2.5);
	rgb+=map(uv*4.2,mouse,.04,u_time*3.3);
	
	rgb=pow(rgb,vec3(.4545));
	
	col=vec4(rgb,1.);
}