Shader "Custom/Unlit/MosaicofSquaresColored" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_Blocks("Number of Blocks", float) = 5
}

SubShader {
    Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
    LOD 100
    
    // ZWrite Off
    Blend SrcAlpha OneMinusSrcAlpha 
    
    Pass {  
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            float random (float2 st) { 
                return frac(sin(dot(st.xy, float2(12.9898,78.233)))*43758.5453123);
            }

            struct appdata_t {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                half2 texcoord : TEXCOORD0;
            };

            float4 _Color;
            float _Blocks;
            
            float4 _MainTex_ST;
            
            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
                o.texcoord = v.texcoord;
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target {            
                return fixed4(_Color.r, _Color.g, _Color.b,
                	random( floor(i.texcoord * float2(_Blocks, _Blocks)) ));
            }
        ENDCG
    }
}

}