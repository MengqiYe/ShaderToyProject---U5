Shader "Custom/TestRim2" {
	Properties{
		_MainColor("MainColor",color)=(1,1,1,1)
		_Scale("Scale",range(1,8))=2
		_Outer("Outer",range(0,1))=0.2
	}
	SubShader {
		Tags { "queue"="transparent" }
		LOD 200
		//使用多个Pass混合来实现外发光
		Pass{
			blend srcalpha oneminussrcalpha
			zwrite off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "unitycg.cginc"
			float4 _MainColor;
			float _Scale;
			float _Outer;
			struct v2f{
				float4 pos: POSITION;
				float3 normal:TEXCOORD0;
				float4 vertex:TEXCOORD1;
			};
			
			v2f vert(appdata_base v)
			{
				//随着法线方向向外延伸
				v.vertex.xyz += v.normal * _Outer;
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
				
				float bright = saturate(dot(N,V));
				bright = pow(bright,_Scale);
				_MainColor.a*=bright;
				return _MainColor;
			}
			
			ENDCG
		}
		
		//=====================================================
		Pass{
			blendop revsub
			blend dstalpha one
			zwrite off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "unitycg.cginc"

			struct v2f{
				float4 pos: POSITION;
			};
			
			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				return o;
			}
			fixed4 frag(v2f IN):COLOR
			{

				return fixed4(1,1,1,1);
			}
			
			ENDCG
		}
		
		//=====================================================
		Pass{
			blend zero one
			//blend srcalpha oneminussrcalpha
			zwrite off
			
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
			
			//====================================================
			
			
			
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
