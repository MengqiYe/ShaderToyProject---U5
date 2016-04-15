Shader "Unlit/BufferB"
{
	Properties{
		iMouse("Mouse Pos", Vector) = (100, 100, 0, 0)
		iChannel0("iChannel0", 2D) = "white" {}
		iChannel1("iChannel1", 2D) = "white" {}
		iChannel2("iChannel2", 2D) = "white" {}
		iChannel3("iChannel3", 2D) = "white" {}
		iChannelResolution0("iChannelResolution", Vector) = (100, 100, 0, 0)
		iChannelResolution1("iChannelResolution", Vector) = (100, 100, 0, 0)
		iChannelResolution2("iChannelResolution", Vector) = (100, 100, 0, 0)
		iChannelResolution3("iChannelResolution", Vector) = (100, 100, 0, 0)
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
		sampler2D iChannel1;
		sampler2D iChannel2;
		sampler2D iChannel3;
		fixed4 iChannelResolution0;
		fixed4 iChannelResolution1;
		fixed4 iChannelResolution2;
		fixed4 iChannelResolution3;

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
			vec2 uv = fragCoord.xy / iResolution.xy;
			vec2 pixelSize = 1. / iResolution.xy;
			vec2 aspect = vec2(1., iResolution.y / iResolution.x);

			vec4 noise = texture2D(iChannel3, fragCoord.xy / iChannelResolution3.xy + fract(vec2(42, 56)*iGlobalTime));

			vec2 lightSize = vec2(4,4);

			// get the gradients from the blurred image
			vec2 d = pixelSize*2.;
			vec4 dx = (texture2D(iChannel2, uv + vec2(1, 0)*d) - texture2D(iChannel2, uv - vec2(1, 0)*d))*0.5;
			vec4 dy = (texture2D(iChannel2, uv + vec2(0, 1)*d) - texture2D(iChannel2, uv - vec2(0, 1)*d))*0.5;

			// add the pixel gradients
			d = pixelSize*1.;
			dx += texture2D(iChannel0, uv + vec2(1, 0)*d) - texture2D(iChannel0, uv - vec2(1, 0)*d);
			dy += texture2D(iChannel0, uv + vec2(0, 1)*d) - texture2D(iChannel0, uv - vec2(0, 1)*d);

			vec2 displacement = vec2(dx.x, dy.x)*lightSize; // using only the red gradient as displacement vector
			float light = pow(max(1. - distance(0.5 + (uv - 0.5)*aspect*lightSize + displacement, 0.5 + (iMouse.xy*pixelSize - 0.5)*aspect*lightSize), 0.), 4.);

			// recolor the red channel
			float v1 = texture2D(iChannel0, uv + vec2(dx.x, dy.x)*pixelSize*8.).x;
			vec4 rd = vec4(v1,v1,v1,v1)*vec4(0.7, 1.5, 2.0, 1.0) - vec4(0.3, 1.0, 1.0, 1.0);

			// and add the light map
			float v2 = 1. - texture2D(iChannel0, uv + vec2(dx.x, dy.x)*pixelSize*8.).x;
			return mix(rd, vec4(8.0, 6., 2., 1.), light*0.75*vec4(v2,v2,v2,v2));

			//gl_FragColor = texture2D(sampler_prev, pixel); // bypass    
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
