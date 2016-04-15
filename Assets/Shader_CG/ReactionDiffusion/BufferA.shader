Shader "Unlit/BufferA"
{
	Properties{
		iMouse("Mouse Pos", Vector) = (100, 100, 0, 0)
		iChannel2("iChannel0", 2D) = "white" {}
		iChannel2("iChannel1", 2D) = "white" {}
		iChannel2("iChannel2", 2D) = "white" {}
		iChannel2("iChannel3", 2D) = "white" {}
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
		sampler2D iChannel1;
		sampler2D iChannel2;
		sampler2D iChannel3;
		float4 iChannelResolution;
		fixed iFrame = 0;

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
			// main reaction-diffusion loop

			// actually the diffusion is realized as a separated two-pass Gaussian blur kernel and is stored in buffer C

#define pi2_inv 0.159154943091895335768883763372

			vec2 complex_mul(vec2 factorA, vec2 factorB){
			return vec2(factorA.x*factorB.x - factorA.y*factorB.y, factorA.x*factorB.y + factorA.y*factorB.x);
		}

		vec2 spiralzoom(vec2 domain, vec2 center, float n, float spiral_factor, float zoom_factor, vec2 pos){
			vec2 uv = domain - center;
			float d = length(uv);
			return vec2(atan(uv.y, uv.x)*n*pi2_inv + d*spiral_factor, -log(d)*zoom_factor) + pos;
		}

		vec2 complex_div(vec2 numerator, vec2 denominator){
			float v1 = numerator.x*denominator.x + numerator.y*denominator.y;
			float v2 = numerator.x*denominator.x - numerator.y*denominator.y;
			return vec2(v1,v2) / vec2(v1,v1);
		}

		float circle(vec2 uv, vec2 aspect, float scale){
			return clamp(1. - length((uv - 0.5)*aspect*scale), 0., 1.);
		}

		float sigmoid(float x) {
			return 2. / (1. + exp2(-x)) - 1.;
		}

		float smoothcircle(vec2 uv, vec2 aspect, float radius, float ramp){
			return 0.5 - sigmoid((length((uv - 0.5) * aspect) - radius) * ramp) * 0.5;
		}

		float conetip(vec2 uv, vec2 pos, float size, float min)
		{
			vec2 aspect = vec2(1., iResolution.y / iResolution.x);
			return max(min, 1. - length((uv - pos) * aspect / size));
		}

		float warpFilter(vec2 uv, vec2 pos, float size, float ramp)
		{
			return 0.5 + sigmoid(conetip(uv, pos, size, -16.) * ramp) * 0.5;
		}

		vec2 vortex_warp(vec2 uv, vec2 pos, float size, float ramp, vec2 rot)
		{
			vec2 aspect = vec2(1., iResolution.y / iResolution.x);

			vec2 pos_correct = 0.5 + (pos - 0.5);
			vec2 rot_uv = pos_correct + complex_mul((uv - pos_correct)*aspect, rot) / aspect;
			float filter = warpFilter(uv, pos_correct, size, ramp);
			return mix(uv, rot_uv, filter);
		}

		vec2 vortex_pair_warp(vec2 uv, vec2 pos, vec2 vel)
		{
			vec2 aspect = vec2(1., iResolution.y / iResolution.x);
			float ramp = 5.;

			float d = 0.2;

			float l = length(vel);
			vec2 p1 = pos;
			vec2 p2 = pos;

			if (l > 0.){
				vec2 normal = normalize(vel.yx * vec2(-1., 1.)) / aspect;
				p1 = pos - normal * d / 2.;
				p2 = pos + normal * d / 2.;
			}

			float w = l / d * 2.;

			// two overlapping rotations that would annihilate when they were not displaced.
			vec2 circle1 = vortex_warp(uv, p1, d, ramp, vec2(cos(w), sin(w)));
			vec2 circle2 = vortex_warp(uv, p2, d, ramp, vec2(cos(-w), sin(-w)));
			return (circle1 + circle2) / 2.;
		}

		vec2 mouseDelta(){
			vec2 pixelSize = 1. / iResolution.xy;
			float eighth = 1. / 8.;
			vec4 oldMouse = texture2D(iChannel2, vec2(7.5 * eighth, 2.5 * eighth));
			vec4 nowMouse = vec4(iMouse.xy / iResolution.xy, iMouse.zw / iResolution.xy);
			if (oldMouse.z > pixelSize.x && oldMouse.w > pixelSize.y &&
				nowMouse.z > pixelSize.x && nowMouse.w > pixelSize.y)
			{
				return nowMouse.xy - oldMouse.xy;
			}
			return vec2(0,0);
		}

		vec4 mainImage(in vec2 fragCoord)
		{
			vec2 uv = fragCoord.xy / iResolution.xy;
			vec2 pixelSize = 1. / iResolution.xy;


			vec2 mouseV = mouseDelta();
			vec2 aspect = vec2(1., iResolution.y / iResolution.x);
			uv = vortex_pair_warp(uv, iMouse.xy*pixelSize, mouseV*aspect*1.4);

			vec4 blur1 = texture2D(iChannel1, uv);

			vec4 noise = texture2D(iChannel3, fragCoord.xy / iChannelResolution.xy + fract(vec2(42, 56)*iGlobalTime));

			// get the gradients from the blurred image
			vec2 d = pixelSize*4.;
			vec4 dx = (texture2D(iChannel1, fract(uv + vec2(1, 0)*d)) - texture2D(iChannel1, fract(uv - vec2(1, 0)*d))) * 0.5;
			vec4 dy = (texture2D(iChannel1, fract(uv + vec2(0, 1)*d)) - texture2D(iChannel1, fract(uv - vec2(0, 1)*d))) * 0.5;

			vec2 uv_red = uv + vec2(dx.x, dy.x)*pixelSize*8.; // add some diffusive expansion

			float new_red = texture2D(iChannel0, fract(uv_red)).x + (noise.x - 0.5) * 0.0025 - 0.002; // stochastic decay
			new_red -= (texture2D(iChannel1, fract(uv_red + (noise.xy - 0.5)*pixelSize)).x -
				texture2D(iChannel0, fract(uv_red + (noise.xy - 0.5)*pixelSize))).x * 0.047; // reaction-diffusion
			vec4 fragColor = vec4(0, 0, 0, 0);
			iFrame += 1;
			if (iFrame<10)
			{
				fragColor = noise;
			}
			else
			{
				fragColor.x = clamp(new_red, 0., 1.);
			}
			return fragColor;
			//    fragColor = noise; // need a restart?
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
