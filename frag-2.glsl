#version 300 es
precision highp float;

uniform float u_time;
uniform vec2 u_resolution;

out vec4 col;

#define S(a,b,x)smoothstep(a,b,x)

void main()
{
	vec2 uv=gl_FragCoord.xy/u_resolution;
	
	float r=0.;
	float w=.25+.24*sin(u_time);
	float s1=S(0.+w,1.-w,uv.x);
	
	if(uv.y<s1){
		r=1.;
	}
	
	col=vec4(r,0.,0.,1.);
}
