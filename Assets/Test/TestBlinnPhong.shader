Shader "Custom/TestBlinnPhong" {
	Properties {
		_SpecularColor("Specular",color)=(1,1,1,1)
		_Shininess("Shininess",range(1,64))=8
	}
	SubShader {
		Pass{
		
			tags{"LightMode" ="ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include"unitycg.cginc"
			#include"lighting.cginc"
			
			float4 _SpecularColor;
			float _Shininess;
			struct v2f {
				float4 pos : POSITION;
				float4 col : COLOR;
			};
			
			v2f vert(appdata_base v)
			{
				v2f o;				
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				
				float3 N = UnityObjectToWorldNormal(v.normal);
				float3 L = normalize(WorldSpaceLightDir(v.vertex));
				float3 V = WorldSpaceViewDir(v.vertex);
				
				//Ambient Color
				o.col = UNITY_LIGHTMODEL_AMBIENT;
				
				//DiffuseColorh
				float ndotl = saturate(dot(N,L)*2);
				o.col = _LightColor0*ndotl;			

				//Specular Color
				//float3 R = 2*dot(N,L)*N - L;
				float3 H = L+V;//半角向量
				H = normalize(H);
				V = normalize(V);
				
				float specularScale = pow(saturate(dot(H,N)),_Shininess);
				
				o.col.rgb += _SpecularColor * specularScale;
					
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


