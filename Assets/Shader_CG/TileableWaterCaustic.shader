Shader "Unlit/TileableWaterCaustic"
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
		#define TAU 6.28318530718
		#define MAX_ITER 5
		vec4 mainImage(vec2 fragCoord);

		fixed4 frag(v2f _iParam) : COLOR0{
			vec2 fragCoord = gl_FragCoord;
			return mainImage(gl_FragCoord);
		}
		vec4 mainImage(in vec2 fragCoord)
		{
			float time = iGlobalTime * .5 + 23.0;
			// uv should be the 0-1 uv of texture...
			vec2 uv = fragCoord.xy / iResolution.xy;

			//#ifdef SHOW_TILING
			//vec2 p = mod(uv*TAU*2.0, TAU) - 250.0;
			//#else
			vec2 p = mod(uv*TAU, TAU) - 250.0;
			//#endif
			vec2 i = vec2(p);
			float c = 1.0;
			float inten = .005;

			for (int n = 0; n < MAX_ITER; n++)
			{
				float t = time * (1.0 - (3.5 / float(n + 1)));
				i = p + vec2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
				c += 1.0 / length(vec2(p.x / (sin(i.x + t) / inten), p.y / (cos(i.y + t) / inten)));
			}
			c /= float(MAX_ITER);
			c = 1.17 - pow(c, 1.4);
			float g = pow(abs(c), 8.0);
			vec3 colour = vec3(pow(abs(c), 8.0), pow(abs(c), 8.0), pow(abs(c), 8.0));
			colour = clamp(colour + vec3(0.5, 0.1, 0), 0.0, 1.0);


			//#ifdef SHOW_TILING
			// Flash tile borders...
			//vec2 pixel = 2.0 / iResolution.xy;
			//uv *= 2.0;

			//float f = floor(mod(iGlobalTime*.5, 2.0)); 	// Flash value.
			//vec2 first = step(pixel, uv) * f;		   	// Rule out first screen pixels and flash.
			//uv = step(fract(uv), pixel);				// Add one line of pixels per tile.
			//colour = mix(colour, vec3(1.0, 1.0, 0.0), (uv.x + uv.y) * first.x * first.y); // Yellow line

			//#endif
			return vec4(colour, 1.0);
		}
		v2f vert(appdata_base v) {
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.srcPos = ComputeScreenPos(o.pos);
			return o;
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