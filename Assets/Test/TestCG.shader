Shader "Custom/TestCG" {

	SubShader {
		pass{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			
			void vert(in float2 objPos:POSITION ,out float4 pos:POSITION, out float4 col:COLOR)
			{
				pos = float4(objPos,0,1);
				col = pos;
				if(pos.x<0&&pos.y<0)
				{
					col = float4(1,0,0,1);
				}
				else if(pos.x<0&&pos.y>0)
				{
					col = float4(0,1,0,1);
				}
				else if(pos.x>0&&pos.y>0)
				{
					col = float4(1,1,0,1);
				}
				else if(pos.x>0,pos.y<0)
				{
					col = float4(0,0,1,1);
				}
			}
			
//			void Func(out float4 c);
//			float Func2(float arr[2])
//			{
//				float sum = 0;
//				for(int i = 0;i<arr.Length;i++)
//				{
//					sum+=arr[i];
//				}
//				return sum;
//			}
			void frag(in float4 pos:POSITION,inout float4 col:COLOR)
			{
				//Func(col);
				//float arr[2] = {0.5,0.5};
				//col.x = 1;
			}
			void Func(out float4 c)
			{
				c = float4(0,1,0,1);
			}		
			ENDCG		
		}
	} 
}
