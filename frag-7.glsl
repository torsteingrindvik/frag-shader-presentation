#version 300 es
precision highp float;

uniform float u_time;
uniform vec2 u_resolution;

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

vec3 map(vec2 uv,float intensity,float t)
{
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
			
			float dist=length(-vec3(cell,.2)+vec3(uvf,0.)+ch);
			
			float glow=pow(intensity/max(.01,dist)*.5,8.)*.152;
			
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
	
	float intensity=.2;
	vec3 rgb=map(uv,intensity,u_time);
	
	float speed=1.2;
	for(int i=0;i<6;i++)
	{
		float fi=float(i);
		rgb+=map(uv*(1.2+fi),.2-(fi*.02),u_time*(1.3+(fi*.5)));
	}
	
	rgb=pow(rgb,vec3(.4545));
	
	col=vec4(rgb,1.);
}