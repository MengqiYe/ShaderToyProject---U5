Shader "Custom/TestVertexTransform" {
	Properties {
		_R("Radius",range(0,5)) = 1
		_CenterX("CenterX",range(-5,5))=0
		_CenterY("CenterY",range(-5,5))=0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include"unitycg.cginc"
			
			float dis;
			float _R;
			float _CenterX;
			float _CenterY;
			
			struct v2f {
				float4 pos : POSITION;
				float4 col : COLOR;
			};
			
			v2f vert(appdata_base v)
			{
				float2 xy = v.vertex.xz;
				//float d = sqrt((xy.x-0)*(xy.x-0)+(xy.y-0)*(xy.y-0));
				float d = _R - length(xy-float2(_CenterX,_CenterY));
				d = d>0?d:0;
				float height = 1;
				float4 uppos = float4(v.vertex.x,d*height,v.vertex.zw);
				
				v2f o;
				//o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.pos = mul(UNITY_MATRIX_MVP,uppos);
				float y = uppos.y/3;
				o.col = fixed4(y,y,y,1);
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
