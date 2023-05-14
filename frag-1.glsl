precision mediump float;

uniform float u_time;
uniform vec2 u_resolution;

#define S(a,b,x)smoothstep(a,b,x)

void main()
{
	vec2 uv=gl_FragCoord.xy/u_resolution;
	
	float EPS=.01;
	float W=2.*EPS;
	
	float ll=.5+.4*sin(u_time*.7);
	
	float lr=ll+W;
	
	float r=S(ll-EPS,ll+EPS,uv.x);
	
	r=r*S(lr+EPS,lr-EPS,uv.x);
	
	gl_FragColor=vec4(r,0.,0.,1.);
}