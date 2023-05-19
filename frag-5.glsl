precision mediump float;

uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_mouse;

#define S(a,b,x)smoothstep(a,b,x)
#define sn(r)(r*sin(u_time))
#define cs(r)(r*cos(u_time))

// https://www.shadertoy.com/view/3syGzz
vec2 repeat(in vec2 p,in float s)
{
	return mod(p+s*.5,s)-s*.5;
}

float map(vec2 uv,vec2 p)
{
	vec2 mouse=p-uv;
	float d=step(.01,length(mouse)-.1);
	
	vec2 offset=vec2(sn(.2),cs(.2));
	
	vec2 ball=repeat(mouse-offset,.2);
	d=min(d,step(.01,length(ball)-.01));
	
	return d;
}

void main()
{
	vec2 r=u_resolution;
	
	vec2 uv=gl_FragCoord.xy/r*2.-1.;
	// correct aspect ratio
	uv.x*=r.x/r.y;
	
	// make mouse agree on coordinate system
	vec2 mouse=u_mouse/r*2.-1.;
	mouse.x*=r.x/r.y;
	
	float l=map(uv,mouse);
	
	gl_FragColor=vec4(vec3(l),1.);
}