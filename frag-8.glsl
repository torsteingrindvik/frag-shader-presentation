#version 300 es
precision highp float;

uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_mouse;

#define S(a,b,x)smoothstep(a,b,x)
#define sn(r)(r*sin(u_time))
#define cs(r)(r*cos(u_time))

out vec4 col;

// https://iquilezles.org/articles/smin/
float smin(in float a,in float b,in float k)
{
	float h=max(0.,k-abs(a-b))/k;
	
	return min(a,b)-h*h*h*k*(1./6.);
}

float lrmin(in float a,in float b,float k,bool left_side)
{
	if(left_side)
	{
		return min(a,b);
	}else{
		return smin(a,b,k);
	}
}

float sphere(in vec2 p,in float radius)
{
	return length(p)-radius;
}

float map(vec2 uv,vec2 mouse,bool left_side)
{
	float res=sphere(uv-vec2(0.,.3),.2);
	res=lrmin(res,sphere(uv-vec2(.5,0.),.2),.4+.4*mouse.x,left_side);
	res=lrmin(res,sphere(uv-vec2(0.,mouse.y*2.-1.),.2),.4+.4*mouse.x,left_side);
	
	return res;
}

void main()
{
	vec2 r=u_resolution;
	
	// -1..1 range
	vec2 uv=gl_FragCoord.xy/r;
	vec2 uv01=uv;
	uv=uv*2.-1.;
	
	vec2 mouse=u_mouse/r;
	
	float w=.01;
	float divider=1.-step(-w,uv.x)*step(-w,-uv.x);
	
	vec3 rgb=vec3(.5);
	
	float res;
	
	if(uv.x<0.){
		// remap UVs to left
		uv.x=uv.x*2.+1.;
		
		res=map(uv,mouse,true);
	}else{
		// remap UVs to right
		uv.x=uv.x*2.-1.;
		
		res=map(uv,mouse,false);
	}
	
	if(res>0.){
		rgb=mix(
			vec3(.1333,.7961,.302),
			vec3(.0706,.4863,.1647),
			.5+.5*sin(uv01.x*10.+u_time*3.)
		);
	}else{
		rgb=mix(
			vec3(.3608,.8706,.8784),
			vec3(.0627,.251,.3176),
			.5+.5*sin(uv01.y*80.+u_time*2.)
		);
	}
	
	rgb=pow(rgb,vec3(.4545));
	
	col=vec4(divider*rgb,1.);
}