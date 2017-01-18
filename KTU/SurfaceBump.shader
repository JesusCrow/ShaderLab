Shader "_KTU/SurfaceBump" {
    Properties {
        _Diffuse ("Diffuse",2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
               
        CGPROGRAM
        #pragma surface surf Custom
       
        half4 LightingCustom( SurfaceOutput s, half3 lightDir, half3 viewDir, half atten )
        {
            half pxlAtten = dot( lightDir, s.Normal );
           
            return half4(s.Albedo * pxlAtten,1.0);
        }
 
        sampler2D _Diffuse;
        sampler2D _NormalMap;
 
        struct Input {
            float2 uv_Diffuse;
        };
 
        void surf (Input IN, inout SurfaceOutput o) {
            o.Albedo = tex2D (_Diffuse, IN.uv_Diffuse).rgb;
            o.Normal = UnpackNormal( tex2D(_NormalMap, IN.uv_Diffuse) );
        }
        ENDCG
    }
}