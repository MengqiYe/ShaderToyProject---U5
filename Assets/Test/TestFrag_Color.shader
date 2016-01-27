Shader "Custom/TestFrag_Color"
{
	Properties
	{
		_MainColor("MainColor",color)=(1,1,1,1)
		_SecondColor("SecondColor",color)=(1,1,1,1)
		_CenterY("CenterY",range(-0.5,0.5))=0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			float4 _MainColor;
			float4 _SecondColor;
			float _CenterY;
			struct v2f{
				float4 pos:POSITION;
				//float4 col:COLOR;
				float y:TEXCOORD0;
			};
			
			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.y = v.vertex.y;
//				if(v.vertex.y<0)
//				{
//					o.col = _MainColor;
//				}
//				else
//				{
//					o.col = _SecondColor;
//				}
				
				return o;
			}
			
			fixed4 frag(v2f IN):COLOR
			{
				if(IN.y>_CenterY)
				{
					return _MainColor;
				}
				else
				{
					return _SecondColor;
				}
			}
			ENDCG
		}
	}
}
