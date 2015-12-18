Shader "Custom/Vogel's Distribution Method 3" {
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
		// Based in part on https://www.shadertoy.com/view/XtsSWM
		
		#define A 2.39996322972865332
		#define N 256.0
		#define R 0.1
		#define PI 3.14159265359    
		
		vec4 mainImage(in vec2 i) {
		    vec2 S=iResolution.xy;
		    i = (i+i-S)/S.y;
		    
		    float w = iGlobalTime * 4.0;
		    i*=dot(i,i+vec2(cos(w),sin(w))*0.1); //warp
		    
		    float r = max(0.1,length(i)-R);
		    float v = floor(r*r*N-w);
		      
		    float c = 1.;
		    for(float k = 0.; k < 40.; k++) {
		        vec2 p = sqrt((v+w)/N)*cos(v*A+vec2(0., PI/2.))-i;
		        c = min(c, dot(p,p));
		        v++;
		    }
		    
		    float g = max(0.,1.-sqrt(c)/R)*max(0.,1.-r);
		    return vec4(g, g*g, g*0.3, 1.);
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

