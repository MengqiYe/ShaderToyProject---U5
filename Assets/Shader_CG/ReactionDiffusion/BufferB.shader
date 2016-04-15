Shader "Unlit/BufferB"
{
	Properties{
		iMouse("Mouse Pos", Vector) = (100, 100, 0, 0)
		iChannel0("iChannel0", 2D) = "white" {}
		iChannelResolution("iChannelResolution", Vector) = (100, 100, 0, 0)
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
		fixed4 iChannelResolution;

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
			// horizontal Gaussian blur pass

		vec4 mainImage(in vec2 fragCoord)
		{
			vec2 pixelSize = 1. / iChannelResolution.xy;
			vec2 uv = fragCoord.xy * pixelSize;

			float h = pixelSize.x;
			vec4 sum = vec4(0,0,0,0);
			sum += texture2D(iChannel0, fract(vec2(uv.x - 4.0*h, uv.y))) * 0.05;
			sum += texture2D(iChannel0, fract(vec2(uv.x - 3.0*h, uv.y))) * 0.09;
			sum += texture2D(iChannel0, fract(vec2(uv.x - 2.0*h, uv.y))) * 0.12;
			sum += texture2D(iChannel0, fract(vec2(uv.x - 1.0*h, uv.y))) * 0.15;
			sum += texture2D(iChannel0, fract(vec2(uv.x + 0.0*h, uv.y))) * 0.16;
			sum += texture2D(iChannel0, fract(vec2(uv.x + 1.0*h, uv.y))) * 0.15;
			sum += texture2D(iChannel0, fract(vec2(uv.x + 2.0*h, uv.y))) * 0.12;
			sum += texture2D(iChannel0, fract(vec2(uv.x + 3.0*h, uv.y))) * 0.09;
			sum += texture2D(iChannel0, fract(vec2(uv.x + 4.0*h, uv.y))) * 0.05;

			return vec4(sum.xyz,1)/ 0.98; // normalize
		}
			ENDCG

			SubShader{
			Pass{
				CGPROGRAM

#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest

				ENDCG
			}
		}
		FallBack Off
}
