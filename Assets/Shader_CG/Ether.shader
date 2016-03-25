Shader "Unlit/Ether"
{
	Properties{
		iMouse ("Mouse Pos", Vector) = (100,100,0,0)
		iChannel0("iChannel0", 2D) = "white" {}  
		iChannelResolution0 ("iChannelResolution0", Vector) = (100,100,0,0)
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
		#define t iGlobalTime

		mat2 m(float a){
			//2D旋转矩阵
			float c=cos(a), s=sin(a);
			return mat2(c,s,-s,c);
		}
		float map(vec3 p){
		    p.xz = mul(m(t*0.4),p.xz);
			p.xy = mul(m(t*0.3),p.xy);
		    vec3 q = p*2.+t*1.;
			//return 1;
			float s = sin(t*0.7);
		    return length(p+vec3(sin(t*0.7),sin(t*0.7),sin(t*0.7)))*log(length(p)+1.) + sin(q.x+sin(q.z+sin(q.y)))*0.5 - 1.;
		}
		
		void mainImage( out vec4 fragColor, in vec2 fragCoord ){	

		}
		fixed4 iMouse;
		sampler2D iChannel0;
		fixed4 iChannelResolution0;
		
		struct v2f {
			float4 pos : SV_POSITION;
			float4 srcPos : TEXCOORD0;
		};
		
		v2f vert(appdata_base v) {  
			v2f o;
			o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
			o.srcPos = ComputeScreenPos(o.pos);  
			return o;
		}
		
		vec4 mainImage(vec2 fragCoord);
		
		fixed4 frag(v2f _iParam) : COLOR0 { 
			vec2 fragCoord = gl_FragCoord;
			return mainImage(gl_FragCoord);
		}

		vec4 mainImage(vec2 fragCoord) {
			vec2 p = fragCoord.xy/iResolution.y - vec2(.9,.5);
			vec3 cl = vec3(0,0,0);
			float d = 2.5;
			for(int i=0; i<=5; i++)	{
				vec3 p3 = vec3(0,0,5.) + normalize(vec3(p, -1.))*d;
				float rz = map(p3);
				float f =  clamp((rz - map(p3+.1))*0.5, -.1, 1. );
				vec3 l = vec3(0.1,0.3,.4) + vec3(5., 2.5, 3.)*f;
				cl = cl*l + (1.-smoothstep(0., 2.5, rz))*.7*l;
				d += min(rz, 1.);
			}
			return vec4(cl, 1.);
		}
		
	ENDCG
	
	SubShader {
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			
			ENDCG
		}
	}
	FallBack Off
}
