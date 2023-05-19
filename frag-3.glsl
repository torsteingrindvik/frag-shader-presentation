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
	float w=u_resolution.x;
	float h=u_resolution.y;
	
	// line width horizontal
	float lw=.02;
	
	// line width vertical
	float lwv=lw;
	
	if(w>h){
		// The render target is wider than it is tall.
		// Therefore we make the line in this axis thinner by this ratio,
		// which compensates for this
		lw*=h/w;
	}else{
		lwv*=w/h;
	}
	
	float my=u_mouse.y/u_resolution.y;
	float r=S(my-lwv,my,uv.y);
	r*=S(my+lwv,my,uv.y);
	
	float mx=u_mouse.x/u_resolution.x;
	float r2=S(mx-lw,mx,uv.x);
	r2*=S(mx+lw,mx,uv.x);
	
	col=vec4(r,r2,0.,1.);
}