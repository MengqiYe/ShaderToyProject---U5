Shader "Unlit/EyeDepth"
{
	SubShader{ // Unity chooses the subshader that fits the GPU best
		Pass{ // some shaders require multiple passes
			ZWrite On
			CGPROGRAM // here begins the part in Unity's Cg

#pragma vertex vert 
#pragma fragment frag
#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : POSITION;
				float4 projPos : TEXCOORD1;
			};

			v2f vert(float4 vertexPos : POSITION)
			{
				v2f OUT;
				OUT.position = mul(UNITY_MATRIX_MVP, vertexPos);
				OUT.projPos = ComputeScreenPos(OUT.position);
				return OUT;
			}

			//camera depth texture here
			uniform sampler2D _CameraDepthTexture; //Depth Texture
			void frag(v2f IN, out float4 color:COLOR, out float depth : DEPTH) // fragment shader
			{
				color = float4(0,0,0,0);
				// use eye depth for actual z...
				depth = LinearEyeDepth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.projPos)).r);
				color = float4(1, 1, 1, 1);
				//or this for depth in between [0,1]
				//depth = Linear01Depth (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.projPos)).r);
			}

			ENDCG // here ends the part in Cg 
		}
	}
}
