Shader "_KTU/Camera/Embosed" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _MainTex;

        struct Input {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o) 
        {
            half4 c = tex2D (_MainTex, IN.uv_MainTex);
            
            float ResS = 720 ;
            float ResT = 720 ;
            
            float2 stp0 = float2(1/ResS, 0);
             
            float2 stpp = float2(1/ResS, 1/ResT);
             
            float3 c00 = tex2D (_MainTex, IN.uv_MainTex).rgb;
             
            float3 cp1p1 = tex2D (_MainTex, IN.uv_MainTex + stpp).rgb;
            
            float3 diffs = c00 - cp1p1;
            float max = diffs.x;
             
            if(abs(diffs.y)>abs(max)) max = diffs.y;
             
            if(abs(diffs.z)>abs(max)) max = diffs.z;
            
            float gray = clamp(max + .5, 0, 1);
             
            
            float r_val = gray*0.9+c00.r*0.1 ;
            float g_val = gray*0.9+c00.g*0.1 ;
            float b_val = gray*0.9+c00.b*0.1 ;
            
            o.Albedo = float3(r_val, g_val, b_val );
            o.Alpha =  1;

 
        }
        ENDCG
    } 
    FallBack "Diffuse"
} 