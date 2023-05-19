#version 300 es
precision highp float;

uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_mouse;

out vec4 col;

// Dave Hoskins, https://www.shadertoy.com/view/4djSRW
vec3 hash23(vec2 p)
{
	vec3 p3=fract(vec3(p.xyx)*vec3(.1031,.1030,.0973));
	p3+=dot(p3,p3.yxz+33.33);
	return fract((p3.xxy+p3.yzz)*p3.zyx);
}

vec3 noise(uvec2 v)
{
	return hash23(vec2(v));
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
			vec3 rng=noise(cell+uvi);
			
			// When mouse is far down, no rng.
			// When far up, add "static" rng as well as time based
			vec3 ch=.8*mouse.y*rng*mix(vec3(1.),.5+.5*sin(u_time*rng),mouse.y);
			
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