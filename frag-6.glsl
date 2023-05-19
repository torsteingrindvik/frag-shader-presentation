precision highp float;

uniform float u_time;
uniform float u_clicks;
uniform vec2 u_resolution;
uniform vec2 u_mouse;

#define S(a,b,x)smoothstep(a,b,x)
#define sn(r)(r*sin(u_time))
#define cs(r)(r*cos(u_time))
#define SK(a,b)smin(a,b,.65);

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

float sea(in vec3 p)
{
	float t=u_time;
	float s=sin(p.x+t)*.2;
	
	return dot(vec3(0.,1.,0.),p-vec3(0.,s-1.4,0.));
}

float map(vec3 p)
{
	float t=u_time;
	
	// sphere positions
	vec3 sph1=vec3(sin(t*1.4),-1.+sin(t),-2.);
	vec3 sph2=vec3(2.,-1.3+sin(t+2.),0.);
	vec3 sph3=vec3(-2.,.3+sin(t+3.),0.);
	vec3 sph4=vec3(13.,1.2,-10.);
	
	// sphere SDF calcs
	float res=sphere(p-sph1,.8);
	res=SK(res,sphere(p-sph2,.6));
	res=SK(res,sphere(p-sph3,.6));
	res=SK(res,sphere(p-sph4,.5));
	
	res=SK(res,sea(p));
	
	return res;
}

vec3 normal(vec3 p)
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

vec3 shading(in vec3 p,in vec3 ro,in vec3 rd,in vec3 n,in vec3 sund)
{
	vec3 res=.5+.5*n;
	
	// TODO: Show only fres
	float fres=pow(1.-dot(-rd,n),9.);
	
	vec3 col=vec3(0.);
	
	float clicks=mod(u_clicks,3.);
	
	if(clicks<.5){
		col+=.2;
	}else if(clicks<1.5){
		col=(.5+.5*n)*fres;
	}else{
		col=(.5+.5*n);
	}
	
	return col;
}

vec3 sky(in vec3 rd,in vec3 sund)
{
	float horiz=pow(1.-max(0.,rd.y),8.);
	
	vec3 sky=mix(
		vec3(.2902,.6078,.7137),
		vec3(.9294,.698,.298),
		horiz
	);
	
	// float sun=max(0.,dot(rd,sund));
	// float sun=clamp(.8+.4*dot(rd,sund),0.,1.);
	
	// sky*=vec3(1.)*sun;
	
	return sky;
}

// Produce a ray direction based on an
// input ray origin and target angle
vec3 cam(in vec2 uv,in vec3 ro,in vec3 ta)
{
	// forward
	vec3 cf=normalize(-ro+ta);
	vec3 cu=normalize(cross(cf,vec3(0.,1.,0.)));
	vec3 cv=normalize(cross(cu,cf));
	
	return normalize(cf+cu*uv.x+cv*uv.y);
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
	
	vec3 m_ta=vec3(mouse,0.);
	vec3 ta=vec3(0.)+m_ta;
	
	vec3 rd=cam(uv,ro,ta);
	vec4 res=march(ro,rd);
	
	vec3 col=vec3(0.);
	vec3 sund=normalize(vec3(3.,2.,2.));
	
	if(res.w>.5){
		vec3 hit=res.xyz;
		vec3 n=normal(hit);
		col=shading(hit,ro,rd,n,sund);
		
	}else{
		col=sky(rd,sund);
	}
	
	col=pow(col,vec3(.4545));
	
	gl_FragColor=vec4(col,1.);
}