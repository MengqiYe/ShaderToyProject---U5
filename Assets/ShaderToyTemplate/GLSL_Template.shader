Shader "Custom/GLSL_Template" {
    Properties{
        iMouse ("Mouse Pos", Vector) = (100,100,0,0)
        iChannel0("iChannel0", 2D) = "white" {}  
        iChannelResolution0 ("iChannelResolution0", Vector) = (100,100,0,0)
    }
    SubShader{
         Tags { "Queue" = "Geometry" }
         Pass
         {
         	GLSLPROGRAM
         	#ifdef VERTEX
         	void main()
         	{
         	   gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
         	}
         	#endif  
         	
         	#ifdef FRAGMENT
         	//这就是从Unity编辑器给GLSL shader传递数据的方法，定义uniforms类型变量
         	uniform vec4 _Color ;
         	void main()
         	{
         	   gl_FragColor = _Color;
         	}
         	#endif
         	ENDGLSL
         }
   }
}
