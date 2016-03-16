Shader "Custom/Furball"{
    Properties{
        iMouse ("Mouse Pos", Vector) = (100,100,0,0)
        iChannel0("iChannel0", 2D) = "white" {}  
        iChannel1("iChannel1", 2D) = "white" {}  
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
        sampler2D iChannel1;
        fixed4 iChannelResolution0;
        const float uvScale = 1.0;
		const float colorUvScale = 0.1;
		const float furDepth = 0.2;
		const int furLayers = 64;
		const float rayStep = 0.00625;
		const float furThreshold = 0.4;
		const float shininess = 50.0;
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
		bool intersectSphere(vec3 ro, vec3 rd, float r, out float t)
		{
			float b = dot(-ro, rd);
			float det = b*b - dot(ro, ro) + r*r;
			if (det < 0.0) return false;
			det = sqrt(det);
			t = b - det;
			return t > 0.0;
		}
		
		vec3 rotateX(vec3 p, float a)
		{
		    float sa = sin(a);
		    float ca = cos(a);
		    return vec3(p.x, ca*p.y - sa*p.z, sa*p.y + ca*p.z);
		}
		
		vec3 rotateY(vec3 p, float a)
		{
		    float sa = sin(a);
		    float ca = cos(a);
		    return vec3(ca*p.x + sa*p.z, p.y, -sa*p.x + ca*p.z);
		}
		
		vec2 cartesianToSpherical(vec3 p)
		{		
			float r = length(p);
		
			float t = (r - (1.0 - furDepth)) / furDepth;	
			p = rotateX(p.zyx, -cos(iGlobalTime*1.5)*t*t*0.4).zyx;	// curl
		
			p /= r;	
			vec2 uv = vec2(atan(p.y, p.x), acos(p.z));
		
			//uv.x += cos(iGlobalTime*1.5)*t*t*0.4;	// curl
			//uv.y += sin(iGlobalTime*1.7)*t*t*0.2;
			uv.y -= t*t*0.1;	// curl down
			return uv;
		}
		
		// returns fur density at given position
		float furDensity(vec3 pos, out vec2 uv)
		{
			uv = cartesianToSpherical(pos.xzy);	
			vec4 tex = texture2D(iChannel0, uv*uvScale);
		
			// thin out hair
			float density = smoothstep(furThreshold, 1.0, tex.x);
			
			float r = length(pos);
			float t = (r - (1.0 - furDepth)) / furDepth;
			
			// fade out along length
			float len = tex.y;
			density *= smoothstep(len, len-0.2, t);
		
			return density;	
		}
		
		// calculate normal from density
		vec3 furNormal(vec3 pos, float density)
		{
		    float eps = 0.01;
		    vec3 n;
			vec2 uv;
		    n.x = furDensity( vec3(pos.x+eps, pos.y, pos.z), uv ) - density;
		    n.y = furDensity( vec3(pos.x, pos.y+eps, pos.z), uv ) - density;
		    n.z = furDensity( vec3(pos.x, pos.y, pos.z+eps), uv ) - density;
		    return normalize(n);
		}
		
		vec3 furShade(vec3 pos, vec2 uv, vec3 ro, float density)
		{
			// lighting
			const vec3 L = vec3(0, 1, 0);
			vec3 V = normalize(ro - pos);
			vec3 H = normalize(V + L);
		
			vec3 N = -furNormal(pos, density);
			//float diff = max(0.0, dot(N, L));
			float diff = max(0.0, dot(N, L)*0.5+0.5);
			float spec = pow(max(0.0, dot(N, H)), shininess);
			
			// base color
			vec3 color = texture2D(iChannel1, uv*colorUvScale).xyz;
		
			// darken with depth
			float r = length(pos);
			float t = (r - (1.0 - furDepth)) / furDepth;
			t = clamp(t, 0.0, 1.0);
			float i = t*0.5+0.5;
				
			return color*diff*i + vec3(spec*i,spec*i,spec*i);
		}	
        vec4 scene(vec3 ro,vec3 rd)
		{
			vec3 p = vec3(0.0,0.0,0.0);
			const float r = 1.0;
			float t;				  
			bool hit = intersectSphere(ro - p, rd, r, t);
			
			vec4 c = vec4(0,0,0,0);
			if (hit) {
				vec3 pos = ro + rd*t;
		
				// ray-march into volume
				for(int i=0; i<10; i++) {
					vec4 sampleCol;
					vec2 uv;
					sampleCol.a = furDensity(pos, uv);
					if (sampleCol.a > 0.0) {
						sampleCol.rgb = furShade(pos, uv, ro, sampleCol.a);
		
						// pre-multiply alpha
						sampleCol.rgb *= sampleCol.a;
						c = c + sampleCol*(1.0 - c.a);
						if (c.a > 0.95) break;
					}
					
					pos += rd*rayStep;
				}
			}
			
			return c;
		}
        vec4 mainImage(in vec2 fragCoord )
		{
			vec2 uv = fragCoord.xy / iResolution.xy;
			uv = uv*2.0-1.0;
			uv.x *= iResolution.x / iResolution.y;
			
			vec3 ro = vec3(0.0, 0.0, 2.5);
			vec3 rd = normalize(vec3(uv, -2.0));
			
			vec2 mouse = iMouse.xy / iResolution.xy;
			float roty = 0.0;
			float rotx = 0.0;
			if (iMouse.z > 0.0) {
				rotx = (mouse.y-0.5)*3.0;
				roty = -(mouse.x-0.5)*6.0;
			} else {
				roty = sin(iGlobalTime*1.5);
			}
			
			ro = rotateX(ro, rotx);	
			ro = rotateY(ro, roty);	
			rd = rotateX(rd, rotx);
			rd = rotateY(rd, roty);
			
			return scene(ro, rd);
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


