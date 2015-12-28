Shader "Custom/TestRim" {
	Properties{
		_Scale("Scale",range(1,8))=2
	}
	SubShader {
		Tags { "queue"="transparent" }
		LOD 200
		Pass{
		blend srcalpha oneminussrcalpha
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "unitycg.cginc"
		float _Scale;
		struct v2f{
			float4 pos: POSITION;
			float3 normal:TEXCOORD0;
			float4 vertex:TEXCOORD1;
		};
		
		v2f vert(appdata_base v)
		{
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
			o.vertex = v.vertex;
			o.normal = v.normal;
			return o;
		}
		fixed4 frag(v2f IN):COLOR
		{
			float3 N = mul(IN.normal,(float3x3)_World2Object);
			N = normalize(N);
			
			float3 worldPos = mul(_Object2World,IN.vertex).xyz;
			float3 V = _WorldSpaceCameraPos.xyz - worldPos;
			V = normalize(V);
			
			float bright = 1.0 - saturate(dot(N,V));
			bright = pow(bright,_Scale);
			return fixed4(1,1,1,1)*bright;
		}
		
		ENDCG
		}
	} 
	FallBack "Diffuse"
}
