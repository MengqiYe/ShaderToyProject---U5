Shader "Custom/TestVertex" {
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
		#include "UnityCG.cginc"
		
		struct v2f{
			float4 pos: POSITION;
			fixed4 col:COLOR;
		};
		float dis;
		float r;
		v2f vert(appdata_base v)
		{
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
			float x = o.pos.x/o.pos.w;
//			if(x<=-1)
//			{
//				o.col = fixed4(1,0,0,1);
//			}
//			else if(x>=1)
//			{
//				o.col = fixed4(0,0,1,1);
//			}
			if(x>dis&&x<dis+r)
			{
				o.col = fixed4(1,0,0,1);
			}
			else
			{
				fixed factor = x/2+0.5;
				o.col = fixed4(factor,factor,factor,1);
			}
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
