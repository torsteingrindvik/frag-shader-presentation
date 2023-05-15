precision mediump float;

uniform float u_time;
uniform vec2 u_resolution;

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
	
	gl_FragColor=vec4(r,0.,0.,1.);
}
