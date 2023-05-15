precision mediump float;

uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_mouse;

#define S(a,b,x)smoothstep(a,b,x)

void main()
{
	vec2 r=u_resolution;
	vec2 uv=gl_FragCoord.xy/r;
	
	float t=floor(mod(u_time,2.));
	if(t<1.){
		uv=uv*2.-1.;
	}
	
	// correct aspect ratio
	uv.x*=r.x/r.y;
	
	float l=5.*length(uv*(.5+.2*sin(u_time)));
	
	gl_FragColor=vec4(vec3(l),1.);
}