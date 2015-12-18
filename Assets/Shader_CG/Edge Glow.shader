Shader "Custom/Edge Glow" {
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

        vec4 mainImage(vec2 fragCoord);

        fixed4 frag(v2f _iParam) : COLOR0 { 
            vec2 fragCoord = gl_FragCoord;
            return mainImage(gl_FragCoord);
        }  
        
		
		float lookup(vec2 p, float dx, float dy)
		{
			float d = sin(iGlobalTime * 5.0)*0.5 + 1.5; // kernel offset
		    vec2 uv = (p.xy + vec2(dx * d, dy * d)) / iResolution.xy;
		    vec4 c = texture2D(iChannel0, uv.xy);
			
			// return as luma
		    return 0.2126*c.r + 0.7152*c.g + 0.0722*c.b;
		}
		
		vec4 mainImage(in vec2 fragCoord )
		{
		    vec2 p = fragCoord.xy;
		    
			// simple sobel edge detection
		    float gx = 0.0;
		    gx += -1.0 * lookup(p, -1.0, -1.0);
		    gx += -2.0 * lookup(p, -1.0,  0.0);
		    gx += -1.0 * lookup(p, -1.0,  1.0);
		    gx +=  1.0 * lookup(p,  1.0, -1.0);
		    gx +=  2.0 * lookup(p,  1.0,  0.0);
		    gx +=  1.0 * lookup(p,  1.0,  1.0);
		    
		    float gy = 0.0;
		    gy += -1.0 * lookup(p, -1.0, -1.0);
		    gy += -2.0 * lookup(p,  0.0, -1.0);
		    gy += -1.0 * lookup(p,  1.0, -1.0);
		    gy +=  1.0 * lookup(p, -1.0,  1.0);
		    gy +=  2.0 * lookup(p,  0.0,  1.0);
		    gy +=  1.0 * lookup(p,  1.0,  1.0);
		    
			// hack: use g^2 to conceal noise in the video
		    float g = gx*gx + gy*gy;
		    float g2 = g * (sin(iGlobalTime) / 2.0 + 0.5);
		    
		    vec4 col = texture2D(iChannel0, p / iResolution.xy);
		    col += vec4(0.0, g, g2, 1.0);		    
		    return col;
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

