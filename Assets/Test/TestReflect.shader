Shader "Custom/TestReflect" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader {
		Pass{
		
			tags{"LightMode" ="ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include"unitycg.cginc"
			#include"lighting.cginc"
			;
			struct v2f {
				float4 pos : POSITION;
				float4 col : COLOR;
			};
			
			v2f vert(appdata_base v)
			{
				v2f o;				
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				
				float3 N = normalize(v.normal);//法线位于物体的坐标系空间
				float3 L = normalize(_WorldSpaceLightPos0);//使用了世界坐标内的光向量
				
				//非等比缩放的情况下，法向量如何变幻？逆矩阵的转置矩阵
				
				N = mul(float4(N,0),_World2Object).xyz;
				N = normalize(N);
				//L = mul(_World2Object,float4(L,0)).xyz;
				
				
				float ndotl = saturate(dot(N,L)*2);
				o.col = _LightColor0*ndotl;				
				return o;
			}
			fixed4 frag(v2f IN):COLOR
			{
				return IN.col+UNITY_LIGHTMODEL_AMBIENT;
			}				
			ENDCG
		} 
	} 
	FallBack "Diffuse"
}
