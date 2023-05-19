#version 300 es
precision highp float;

uniform float u_time;
uniform vec2 u_resolution;

out vec4 col;

const mat2 m=mat2(.80,.60,-.60,.80);

// Dave Hoskins, https://www.shadertoy.com/view/4djSRW
vec3 hash23(vec2 p)
{
	vec3 p3=fract(vec3(p.xyx)*vec3(.1031,.1030,.0973));
	p3+=dot(p3,p3.yxz+33.33);
	return fract((p3.xxy+p3.yzz)*p3.zyx);
}

vec3 noise(ivec2 v)
{
	return hash23(vec2(v));
}

vec3 map(vec2 uv,float intensity,float t)
{
	uv*=3.;
	
	ivec2 uvi=ivec2(floor(uv));
	vec2 uvf=fract(uv)-.5;
	
	vec3 col=vec3(0.);
	
	for(int i=-1;i<=1;i++)
	{
		for(int j=-1;j<=1;j++)
		{
			ivec2 cell=ivec2(i,j);
			vec3 rng=noise(cell+uvi);
			
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
	
	vec2 uv=gl_FragCoord.xy/r*2.-1.;
	// correct aspect ratio
	uv.x*=r.x/r.y;
	
	float intensity=.2;
	vec3 rgb=map(uv,intensity,u_time);
	
	float speed=1.2;
	for(int i=0;i<6;i++)
	{
		float fi=float(i);
		rgb+=map(uv*(1.2+fi),.2-(fi*.02),u_time*(1.3+(fi*.5)));
		uv*=m;
	}
	
	rgb=pow(rgb,vec3(.4545));
	
	col=vec4(rgb,1.);
}