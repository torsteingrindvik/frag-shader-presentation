#version 300 es
precision highp float;

uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_mouse;

out vec4 col;

#define S(a,b,x)smoothstep(a,b,x)

void main()
{
	vec2 uv=gl_FragCoord.xy/u_resolution;
	
	float mx=u_mouse.x/u_resolution.x;
	
	float EPS=.001+.03*mx;
	float W=.08;
	float t=floor(mod(u_time,3.));
	
	float ll=.5+.3*sin(u_time*.4);
	float lr=ll+W;
	
	float r=0.;
	float g=0.;
	
	float s1=S(ll-EPS,ll+EPS,uv.x);
	float s2=S(lr+EPS,lr-EPS,uv.x);
	
	if(t<1.){
		r=s1;
	}else if(t<2.){
		g=s2;
	}else{
		r=s1*s2;
		g=r;
	}
	
	col=vec4(r,g,0.,1.);
}