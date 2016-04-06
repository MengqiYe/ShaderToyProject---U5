Shader "Unlit/Creepy Mountain"
{
	Properties{
		iMouse("Mouse Pos", Vector) = (100, 100, 0, 0)
		iChannel0("iChannel0", 2D) = "white" {}
		iChannelResolution0("iChannelResolution0", Vector) = (100, 100, 0, 0)
	}

	CGINCLUDE
		#include "UnityCG.cginc"
		#pragma target 3.0
		
		#define vec2 float2
		#define vec3 float3
		#define vec4 float4
		#define mat2 float2x2
		#define iGlobalTime _Time.y
		#define mod fmod
		#define mix lerp
		#define atan atan2
		#define fract frac 
		#define texture2D tex2D
		// 屏幕的尺寸
		#define iResolution _ScreenParams
		// 屏幕中的坐标，以pixel为单位
		#define gl_FragCoord ((_iParam.srcPos.xy/_iParam.srcPos.w)*_ScreenParams.xy) 
		
		#define PI2 6.28318530718
		#define pi 3.14159265358979
		#define halfpi (pi * 0.5)
		#define oneoverpi (1.0 / pi)

		fixed4 iMouse;
		sampler2D iChannel0;
		fixed4 iChannelResolution0;

		struct v2f {
			float4 pos : SV_POSITION;
			float4 srcPos : TEXCOORD0;
		};

		v2f vert(appdata_base v) {
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.srcPos = ComputeScreenPos(o.pos);
			return o;
		}

		vec4 mainImage(vec2 fragCoord);

		fixed4 frag(v2f _iParam) : COLOR0{
			vec2 fragCoord = gl_FragCoord;
			return mainImage(gl_FragCoord);
		}

	ENDCG

		SubShader{
			Pass{
				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest

				float noise(vec2 p)
				{
					return texture2D(iChannel0, p).x;
				}

				float fnoise(vec2 uv, vec4 sc) {
					float f = sc.x*noise(uv); uv = 2.*uv + .11532185;
					f += sc.y*noise(uv); uv = 2.*uv + .23548563;
					f += sc.z*noise(uv); uv = 2.*uv + .12589452;
					f += sc.w*noise(uv); uv = 2.*uv + .26489542;
					return f;
				}


				float terrain(float x) {
					float w = 0.;
					float a = 1.;
					x *= 20.;
					w += sin(x*.3521)*4.;
					for (int i = 0; i<5; i++) {
						x *= 1.53562;
						x += 7.56248;
						w += sin(x)*a;
						a *= .5;
					}
					return .2 + w*.015;
				}

				float bird(vec2 p) {
					p.x += iGlobalTime*.05;
					float t = iGlobalTime*.05 + noise(vec2(floor(p.x / .4 - .2)*.7213548))*.7;
					p.x = mod(p.x, .4) - .2;
					p *= 2. - mod(t, 1.)*2.;
					p.y += .6 - mod(t, 1.);
					p.y += pow(abs(p.x), 2.)*20.*(.2 + sin(iGlobalTime*20.));
					float s = step(0.003 - abs(p.x)*.1, abs(p.y));
					return min(s, step(0.005, length(p + vec2(0., .0015))));
				}

				float tree(vec2 p, float tx) {
					float noisev = noise(p.xx*.1 + .552121)*.25;
					p.x = mod(p.x, .2) - .1;
					p *= 15. + noise(vec2(tx*1.72561))*10.;
					float ot = 1000.;
					float a = radians(-60. + noise(vec2(tx))*30.);
					for (int i = 0; i<7; i++) {
						ot = min(ot, length(max(vec2(0.), abs(p) - vec2(-a*.15, .9))));
						float s = (sign(p.x) + 1.)*.25;
						p.x = abs(p.x);
						p = p*1.3 - vec2(0., 1. + noisev);
						a *= .8;
						a -= (noise(vec2(float(i + 2)*.55170275 + tx, s)) - .5)*.2;
						mat2 rot = mat2(cos(a), sin(a), -sin(a), cos(a));
						p *= rot;
					}
					return step(0.05, ot);
				}


				float scene(vec2 p) {
					float t = terrain(p.x);
					float s = step(0., p.y + t);
					float tx = floor(p.x / .2)*.2 + .1;
					if (noise(vec2(tx*3.75489))>.55) s = min(s, tree(p + vec2(0., terrain(tx)), .42 + tx*4.5798523));
					s = min(s, bird(p));
					return s;
				}

				float aascene(vec2 p) {
					vec2 pix = vec2(0., max(.25, 6. - iGlobalTime) / iResolution.x);
					float aa = scene(p);
					aa += scene(p + pix.xy);
					aa += scene(p + pix.yy);
					aa += scene(p + pix.yx);
					return aa*.25;
				}

				void mainImage(out vec4 fragColor, in vec2 fragCoord)
				{
					vec2 uv = fragCoord.xy / iResolution.xy - .5;
					uv.x *= iResolution.x / iResolution.y;
					float v = 0., l;
					float t = iGlobalTime*.05;
					vec2 c = vec2(-t, 0.);
					vec2 p;
					float sc = clamp(t*t*.5, .05, .15);
					uv.y -= .25;
					uv.x -= .2;
					for (int i = 0; i<50; i++) {
						p = uv*sc;
						l = pow(max(0., 1. - length(p)*2.), 15.);
						l = .02 + l*.8;
						v += scene(p + c)*pow(float(i + 1) / 30., 2.)*l;
						sc += .006;
					}
					float clo = fnoise((uv - vec2(t, 0.))*vec2(.03, .15), vec4(.8, .6, .3, .1))*max(0., 1. - uv.y*3.);
					float tx = uv.x - t*.5;
					float ter = .5 + step(0., uv.y - fnoise(vec2(tx)*.015,
						vec4(1., .5, .3, .1))*(.23*(1. + sin(tx*3.2342)*.25)) + .5);
					float s = aascene(p + c)*(ter + clo*.4);
					v *= .025;
					float col = min(1., .05 + v + s*l);
					col = sqrt(col)*2.05 - .5;
					fragColor = vec4(col*min(1., iGlobalTime*.2));
				}
				ENDCG
			}
		}
		FallBack Off
}
