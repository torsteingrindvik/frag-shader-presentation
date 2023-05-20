#version 300 es
precision highp float;

uniform float u_time;
uniform float u_clicks;
uniform vec2 u_resolution;
uniform vec2 u_mouse;

#define S(a,b,x)smoothstep(a,b,x)
#define sn(r)(r*sin(u_time))
#define cs(r)(r*cos(u_time))
#define SK(a,b)smin(a,b,.65)

#define MODE()mod(u_clicks+0.,5.)
#define MOUSE()(u_mouse/u_resolution)

out vec4 col;

const mat2 m=mat2(.80,.60,-.60,.80);

// https://iquilezles.org/articles/smin/
float smin(in float a,in float b,in float k)
{
	float h=max(0.,k-abs(a-b))/k;
	
	return min(a,b)-h*h*h*k*(1./6.);
}

float sphere(in vec3 p,in float radius)
{
	return length(p)-radius;
}

float noise(in vec2 p){
	return sin(p.x)*sin(p.y);
}

// iq: https://www.shadertoy.com/view/lsl3RH
float fbm3(in vec2 p)
{
	float f=0.;
	f+=.5*noise(p);
	p*=m*2.02;
	
	f+=.25*noise(p);
	p*=m*2.03;
	
	f+=.125*noise(p);
	p*=m*2.04;
	
	return f/.875;
}

float map(vec3 p)
{
	float t=u_time;
	float m=MODE();
	
	vec3 sph=vec3(0.,.2,-1.);
	
	// base radius
	float r=1.;
	// time radius
	float tr=.1*sin(u_time*5.);
	
	float res=sphere(p-sph,r);
	
	#define FLOOR()(res=min(res,p.y+3.1));
	
	FLOOR();
	
	if(m>.5&&m<1.5){
		res=sphere(p-sph,r+tr);
		FLOOR();
	}else if(m>1.5&&m<2.5){
		res=sphere(p-sph,r+.04*sin(p.y*(1.+100.*MOUSE().y))+tr);
		FLOOR();
	}else if(m>2.5&&m<3.5){
		float my=clamp(1.+MOUSE().y*2.,0.,3.);
		res=sphere(p-sph,r+.34*fbm3(p.xz*my+u_time*1.)+tr);
		FLOOR();
	}
	
	return res;
}

vec3 normal(in vec3 p)
{
	const vec2 EPS=vec2(.001,0.);
	
	return normalize(
		vec3(
			map(p+EPS.xyy)-map(p-EPS.xyy),
			map(p+EPS.yxy)-map(p-EPS.yxy),
			map(p+EPS.yyx)-map(p-EPS.yyx)
		)
	);
}

vec4 march(in vec3 ro,in vec3 rd)
{
	const float EPS=.0001;
	
	// We can think of this as 80 meters.
	float t_max=80.;
	float t=0.;
	
	vec2 res=vec2(-1.);
	
	for(int i=0;i<512;i++)
	{
		vec3 p=ro+rd*t;
		
		float d=map(p);
		
		if(d<EPS){
			return vec4(p,1.);
		}
		t+=d;
		if(t>t_max){
			break;
		}
	}
	
	return vec4(0.);
}

// returns 0.0 for completely in shadow,
// up towards 1.0 for completely visible
float soft_shadows(in vec3 p,in vec3 sund,float k){
	float t=.1;
	float soft=1.;
	
	for(int i=0;i<30&&t<100.;i++){
		float hit=map(p+sund*t);
		
		soft=min(soft,k*hit/t);
		if(soft<.01){
			soft=0.;
			break;
		}
		
		t+=hit;
	}
	
	soft=clamp(soft,.48,1.);
	return soft*soft*(3.-2.*soft);
}

// Produce a ray direction based on an
// input ray origin and target angle.
vec3 cam(in vec2 uv,inout vec3 ro,in vec3 ta)
{
	// forward
	vec3 cf=normalize(-ro+ta);
	vec3 cu=normalize(cross(cf,vec3(0.,1.,0.)));
	vec3 cv=normalize(cross(cu,cf));
	
	return normalize(cf+cu*uv.x+cv*uv.y);
}

void main()
{
	col=vec4(.9647,.9765,.7569,1.);
	
	vec2 r=u_resolution;
	
	vec2 uv01=gl_FragCoord.xy/r;
	vec2 uv=uv01*2.-1.;
	
	col.rgb=mix(col.rgb,col.rgb*.3,1.-uv01.y);
	
	// correct aspect ratio
	uv.x*=r.x/r.y;
	
	// make mouse agree on coordinate system
	vec2 mouse=u_mouse/r*2.-1.;
	mouse.x*=r.x/r.y;
	
	vec3 ro=vec3(.0,.3,2.3);
	
	vec3 m_ta=vec3(mouse.x,.2,0.);
	vec3 ta=vec3(0.)+m_ta;
	
	// camera perspective
	vec3 rd=cam(uv,ro,ta);
	
	vec4 res=march(ro,rd);
	
	vec3 sund=normalize(vec3(1.,1.8,2.3));
	
	if(res.w>.5){
		vec3 p=res.xyz;
		vec3 n=normal(p);
		col.rgb=.5+.5*n;
		
		// soft shadows
		float ss=soft_shadows(p+.1*n,sund,2.5);
		
		col.rgb*=vec3(ss);
	}
	
	col.rgb=pow(col.rgb,vec3(.4545));
}