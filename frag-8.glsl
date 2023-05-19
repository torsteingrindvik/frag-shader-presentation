#version 300 es
precision highp float;

uniform float u_time;
uniform float u_clicks;
uniform vec2 u_resolution;
uniform vec2 u_mouse;

#define S(a,b,x)smoothstep(a,b,x)
#define sn(r)(r*sin(u_time))
#define cs(r)(r*cos(u_time))
#define SK(a,b)smin(a,b,.65);

out vec4 col;

const mat2 m=mat2(.80,.60,-.60,.80);

// TODO: Link iq
float smin(in float a,in float b,in float k)
{
	float h=max(0.,k-abs(a-b))/k;
	
	return min(a,b)-h*h*h*k*(1./6.);
}

float sphere(in vec3 p,in float radius)
{
	return length(p)-radius;
}

// https://www.shadertoy.com/view/3syGzz
vec2 repeat(in vec2 p,in float s)
{
	return mod(p+s*.5,s)-s*.5;
}

float hash21(in vec2 i)
{
	return fract(
		sin(
			dot(
				floor(i),
				vec2(127.1,3423.2)
			)
		)*32525.123
	);
}

float noise(in vec2 p){
	return sin(p.x)*sin(p.y);
}

// iq: https://www.shadertoy.com/view/lsl3RH
float fbm2(in vec2 p)
{
	float f=0.;
	f+=.5*noise(p);
	p*=m*2.02;
	
	f+=.25*noise(p);
	p*=m*2.03;
	
	return f/.75;
}
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
float fbm4(in vec2 p)
{
	float f=0.;
	f+=.5*noise(p);
	p*=m*2.02;
	
	f+=.25*noise(p);
	p*=m*2.03;
	
	f+=.125*noise(p);
	p*=m*2.04;
	
	f+=.065*noise(p);
	p*=m*2.01;
	
	return f/.94;
}

float sea(in vec3 p)
{
	float t=u_time;
	
	// slow big
	float s=fbm3(p.xz*.08-t*.4)*1.25;
	
	s+=fbm2(p.xz+t*.9)*.1;
	s+=fbm3(p.xz*.8-t*.4)*.25;
	
	return dot(vec3(0.,1.,0.),p-vec3(0.,s-2.4,0.));
}

float map(vec3 p,float camp)
{
	float t=u_time;
	
	// sphere positions
	vec3 sph1=vec3(sin(t*1.4),-1.+sin(t),-2.);
	vec3 sph2=vec3(2.,-1.3+sin(t+2.),0.);
	vec3 sph3=vec3(-2.,.3+sin(t+3.),0.);
	vec3 sph4=vec3(13.,1.2,-10.);
	
	float res=sea(p);
	
	float dim=dot(p,p)*.0002;
	
	vec2 rep=repeat(p.xz,10.);
	vec3 prep=vec3(rep.x,p.y,rep.y);
	
	// sphere SDF calcs
	res=SK(res,sphere(prep-sph1,max(0.,.8-dim)));
	res=SK(res,sphere(prep-sph2,max(0.,.6-dim)));
	res=SK(res,sphere(prep-sph3,max(0.,.6-dim)));
	res=SK(res,sphere(prep-sph4,max(0.,.5-dim)));
	
	res=SK(res,sea(p));
	
	return res;
}

vec3 normal(in vec3 p,in float camp)
{
	const vec2 EPS=vec2(.001,0.);
	
	return normalize(
		vec3(
			map(p+EPS.xyy,camp)-map(p-EPS.xyy,camp),
			map(p+EPS.yxy,camp)-map(p-EPS.yxy,camp),
			map(p+EPS.yyx,camp)-map(p-EPS.yyx,camp)
		)
	);
}

vec4 march(in vec3 ro,in vec3 rd,in float camp)
{
	const float EPS=.0001;
	
	// We can think of this as 80 meters.
	float t_max=80.;
	float t=0.;
	
	vec2 res=vec2(-1.);
	
	for(int i=0;i<512;i++)
	{
		vec3 p=ro+rd*t;
		
		float d=map(p,camp);
		
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

vec3 sky(in vec3 rd,in vec3 sund)
{
	float horiz=pow(1.-max(0.,rd.y),8.);
	
	vec3 sky=mix(
		vec3(.2902,.6078,.7137),
		vec3(.9294,.698,.298),
		horiz
	);
	
	float sun=max(0.,dot(rd,sund));
	
	sky+=vec3(1.,.8431,.2196)*pow(sun,200.);
	
	return clamp(sky,0.,1.);
}

vec3 shading(in vec3 p,in vec3 ro,in vec3 rd,in vec3 n,in vec3 sund,in float camp)
{
	float clicks=mod(u_clicks+0.,5.);
	
	// base color: normals for now
	vec3 col=.1*vec3(.9,.8,1.9)+.14*n;
	
	// "view vector factor"
	float viewf=dot(-rd,n);
	
	// fresnel
	float fres=pow(1.-viewf,5.);
	
	// specular
	vec3 H=normalize(-rd+sund);
	vec3 spec=pow(max(0.,dot(H,n)),40.)*(1.-vec3(fres));
	
	// reflections
	vec3 sky_ref=sky(reflect(rd,n),sund)*max(.0,pow(1.-viewf,2.));
	
	// mode to show
	if(clicks<.5){
		col*=.01;
	}else if(clicks<1.5){
		col*=fres;
	}
	else if(clicks<2.5){
		col*=spec;
	}
	else if(clicks<3.5){
		col*=sky_ref;
	}else{
		col+=.5*sky(rd,sund)*(2.8*spec+fres*1.2)+.5*(sky_ref*vec3(1.,1.,1.));
	}
	
	// distance attenuation
	vec3 dist_vec=-ro+p;
	float at=1.-max(0.,1.-dot(dist_vec,dist_vec)*.0002);
	at*=(1.-camp);
	
	col=mix(col,sky(rd,sund),at);
	
	return col;
}

// Produce a ray direction based on an
// input ray origin and target angle.
//
// f is a factor which mixes between perspective (0.0) and ortho (1.0)
vec3 cam(in vec2 uv,inout vec3 ro,in vec3 ta,in float f)
{
	// forward
	vec3 cf=normalize(-ro+ta);
	vec3 cu=normalize(cross(cf,vec3(0.,1.,0.)));
	vec3 cv=normalize(cross(cu,cf));
	
	vec3 rd_persp=normalize(cf+cu*uv.x+cv*uv.y);
	vec3 rd_ortho=cf;
	
	vec3 ro_persp=ro;
	vec3 ro_ortho=ro+3.*(uv.x*cu+uv.y*cv);
	
	ro=mix(ro_persp,ro_ortho,f);
	vec3 rd=mix(rd_persp,rd_ortho,f);
	
	return rd;
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
	
	vec3 ro=vec3(.2,.2,2.3);
	
	vec3 m_ta=vec3(mouse.x,.2,0.);
	vec3 ta=vec3(0.)+m_ta;
	
	// camera perspective
	float camp=clamp(.5+.8*mouse.y,0.,1.);
	vec3 rd=cam(uv,ro,ta,camp);
	
	vec4 res=march(ro,rd,camp);
	
	vec3 sund=normalize(vec3(1.,2.,-4.3));
	
	col.a=1.;
	
	if(res.w>.5){
		vec3 hit=res.xyz;
		vec3 n=normal(hit,camp);
		col.rgb=shading(hit,ro,rd,n,sund,camp);
		
	}else{
		col.rgb=sky(rd,sund);
	}
	
	col.rgb=pow(col.rgb,vec3(.4545));
}