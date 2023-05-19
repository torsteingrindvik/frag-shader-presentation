#version 300 es
precision highp float;

uniform float u_time;
uniform vec2 u_resolution;

out vec4 col;

#define S(a,b,x)smoothstep(a,b,x)

void main()
{
	vec2 uv=gl_FragCoord.xy/u_resolution;
	
	float t=floor(mod(u_time,3.));
	
	if(t<1.){
		col=vec4(fract(uv.x),0.,0.,1.);
	}else if(t<2.){
		col=vec4(0.,fract(uv.y),0.,1.);
	}else{
		col=vec4(fract(uv),0.,1.);
		
	}
}