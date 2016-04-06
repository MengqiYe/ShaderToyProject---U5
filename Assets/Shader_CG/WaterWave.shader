Shader "Unlit/WaterWave"
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

		// Simple Water shader. (c) Victor Korsun, bitekas@gmail.com; 2012.
		//
		// Attribution-ShareAlike CC License.



		const float PI = 3.1415926535897932;

		// play with these parameters to custimize the effect
		// ===================================================

		//speed
		const float speed = 0.2;
		const float speed_x = 0.3;
		const float speed_y = 0.3;

		// refraction
		const float emboss = 0.50;
		const float intensity = 2.4;
		const int steps = 8;
		const float frequency = 6.0;
		const int angle = 7; // better when a prime

		// reflection
		const float delta = 60.;
		const float intence = 700.;

		const float reflectionCutOff = 0.012;
		const float reflectionIntence = 200000.;

		// ===================================================

		float time;

		float col(vec2 coord)
		{
			float delta_theta = 2.0 * PI / float(angle);
			float col = 0.0;
			float theta = 0.0;
			time = iGlobalTime*1.3;
			for (int i = 0; i < steps; i++)
			{
				vec2 adjc = coord;
				theta = delta_theta*float(i);
				adjc.x += cos(theta)*time*speed + time * speed_x;
				adjc.y -= sin(theta)*time*speed - time * speed_y;
				col = col + cos((adjc.x*cos(theta) - adjc.y*sin(theta))*frequency)*intensity;
			}

			return cos(col);
		}


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

		//---------- main
		vec4 mainImage(in vec2 fragCoord)
		{
			vec2 p = (fragCoord.xy) / iResolution.xy, c1 = p, c2 = p;
			float cc1 = col(c1);

			c2.x += iResolution.x / delta;
			float dx = emboss*(cc1 - col(c2)) / delta;

			c2.x = p.x;
			c2.y += iResolution.y / delta;
			float dy = emboss*(cc1 - col(c2)) / delta;

			c1.x += dx*2.;
			c1.y = -(c1.y + dy*2.);

			float alpha = 1. + dot(dx, dy)*intence;

			float ddx = dx - reflectionCutOff;
			float ddy = dy - reflectionCutOff;
			if (ddx > 0. && ddy > 0.)
				alpha = pow(alpha, ddx*ddy*reflectionIntence);

			vec4 col = texture2D(iChannel0, c1)*(alpha);
			return col;
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