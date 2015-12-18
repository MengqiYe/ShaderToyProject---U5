Shader "Custom/Water Columns" {
    Properties{
        iMouse ("Mouse Pos", Vector) = (100,100,0,0)
        iChannel0("iChannel0", 2D) = "white" {}  
        iChannelResolution0 ("iChannelResolution0", Vector) = (100,100,0,0)
    }

    CGINCLUDE    
        #include "UnityCG.cginc"   
        #pragma target 3.0      

        #define vec2 float2
        #define vec3 float3
        #define vec4 float4
        #define mat2 float2x2
        #define iGlobalTime _Time.y
        #define mod fmod
        #define mix lerp
        #define atan atan2
        #define fract frac 
        #define texture2D tex2D
        // 屏幕的尺寸
        #define iResolution _ScreenParams
        // 屏幕中的坐标，以pixel为单位
        #define gl_FragCoord ((_iParam.srcPos.xy/_iParam.srcPos.w)*_ScreenParams.xy) 

        #define PI2 6.28318530718
        #define pi 3.14159265358979
        #define halfpi (pi * 0.5)
        #define oneoverpi (1.0 / pi)

        fixed4 iMouse;
        sampler2D iChannel0;
        fixed4 iChannelResolution0;
        
        struct v2f {    
            float4 pos : SV_POSITION;    
            float4 srcPos : TEXCOORD0;   
        };              

        v2f vert(appdata_base v) {  
            v2f o;
            o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
            o.srcPos = ComputeScreenPos(o.pos);  
            return o;    
        }  
        
        vec4 mainImage(in vec2 fragCoord )
		{		
			const bool leftToRight = false;
			float slopeSign = (leftToRight ? -1.0 : 1.0);
			float slope1 = 5.0 * slopeSign;
			float slope2 = 7.0 * slopeSign;
			vec2 uv = fragCoord.xy / iResolution.xy;
			float bright = 
			- sin(uv.y * slope1 + uv.x * 30.0+ iGlobalTime *3.10) *.2 
			- sin(uv.y * slope2 + uv.x * 37.0 + iGlobalTime *3.10) *.1
			- cos(              + uv.x * 2.0 * slopeSign + iGlobalTime *2.10) *.1 
			- sin(              - uv.x * 5.0 * slopeSign + iGlobalTime * 2.0) * .3;
			
			float modulate = abs(cos(iGlobalTime*.1) *.5 + sin(iGlobalTime * .7)) *.5;
			bright *= modulate;
			vec4 pix = texture2D(iChannel0,uv);
			pix.rgb += clamp(bright / 1.0,0.0,1.0);
			return pix;
		}

        fixed4 frag(v2f _iParam) : COLOR0 { 
            vec2 fragCoord = gl_FragCoord;
            return mainImage(gl_FragCoord);
        }  

    ENDCG    

    SubShader {    
        Pass {    
            CGPROGRAM    

            #pragma vertex vert    
            #pragma fragment frag    
            #pragma fragmentoption ARB_precision_hint_fastest     

            ENDCG    
        }    
    }     
    FallBack Off    
}

