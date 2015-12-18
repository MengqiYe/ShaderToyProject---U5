Shader "Custom/Glow" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_Cutoff ("Cutoff", Range(0,1))=0.5
		_Power ("Power", Range(0.5, 8.0)) = 3.0
	}
	SubShader {
		Tags { "Queue"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf SimpleLambert alpha
		
		half4 _Color;
		half _Cutoff;
		half _Power;
		
		half4 LightingSimpleLambert (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {	
			half4 c = _Color;
			return c;	
		}
		
		
		struct Input {
			float2 uv_MainTex;
			half3 viewDir;
		};
		//normalize:归一化向量
		//dot:返回A和 B的点积(dot product)。参数A和B可以是标量，也可以是向量（输入参数方面，点积和叉积函数有很大不同）。 
		//saturate:如果x小于0，返回0；如果 x大于 1，返回1；否则，返回 x
		//pow(x,y):x的y次方
		void surf (Input IN, inout SurfaceOutput o) {
			half4 c = _Color;	
			half ndv=saturate(dot(o.Normal,normalize(IN.viewDir)));
			o.Emission = c.rgb;
			//o.Alpha = c.a*pow ((ndv-_Cutoff)/(1-_Cutoff+0.00001),_Power);
			o.Alpha = c.a*pow(ndv,_Power);
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
