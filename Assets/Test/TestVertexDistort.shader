Shader "Custom/TestVertexDistort" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include"unitycg.cginc"
			;
			struct v2f {
				float4 pos : POSITION;
				float4 col : COLOR;
			};
			
			v2f vert(appdata_base v)
			{
				float angle = length(v.vertex)*_SinTime.w;
//				float4x4 rm = {
//					float4(cos(angle),0,sin(angle),0),
//					float4(0,1,0,0),
//					float4(-sin(angle),0,cos(angle),0),
//					float4(0,0,0,1)
//				};
//				//mul(ma,mb)矩阵a影响矩阵b 
//				rm = mul(UNITY_MATRIX_MVP,rm);
//				v.vertex = mul(rm,v.vertex);
				
//				//矩阵计算优化
//				float x = cos(angle)*v.vertex.x + sin(angle)*v.vertex.z;
//				float z = cos(angle)*v.vertex.z - sin(angle)*v.vertex.x;
//				
//				v.vertex.x = x;
//				v.vertex.z = z;

				float4x4 rm = {
					float4(sin(angle)/8+0.5,0,0,0),
					float4(0,1,0,0),
					float4(0,0,1,0),
					float4(0,0,0,1)
				};				
				v.vertex = mul(rm,v.vertex);
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				return o;
			}
			fixed4 frag():COLOR
			{
				return fixed4(.5,.5,1,1);
			}				
			ENDCG
		} 
	} 
	FallBack "Diffuse"
}
