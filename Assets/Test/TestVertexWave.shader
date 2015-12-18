Shader "Custom/TestVertexWave" {
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
				// A * sin(w*x+t)简谐运动，sin正弦波
				//v.vertex.y += .2*sin((1/length(v.vertex.xz)-float2(0,0))*10*1+_Time.y);
				v.vertex.y += .2*sin((v.vertex.x + v.vertex.z)*1+_Time.y);
				v.vertex.x += .3*sin((v.vertex.x - v.vertex.z)*1+_Time.w);
				v2f o;				
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.col = float4(v.vertex.y,v.vertex.y,v.vertex.y,1);
				return o;
			}
			fixed4 frag(v2f IN):COLOR
			{
				return IN.col;
			}				
			ENDCG
		} 
	} 
	FallBack "Diffuse"
}
