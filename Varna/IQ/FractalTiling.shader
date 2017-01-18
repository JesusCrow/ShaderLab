// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Ported to ShaderLab by Paulius Varna, 2017

Shader "_IQ/FractalTiling" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_Cycles("Number of Cycles", int) = 6
	_RandomColor ("Color of Randoms", Color) = (0.035, 0.01, 0.0, 0.7)
	_Random ("Random value", float) = 13.545317
	_Periods ("Light impulse periods", float) = 0.01
	_SinX ("Sin X", float) = 7.0
	_SinY ("Sin Y", float) = 31.0
	_ColIntensityMin ("Lower value of color Intensity", float) = 0.45
	_ColIntensityMax ("Higher value of color Intensity", float) = 0.55
	_ColorShape ("Color Shape", Color) = (1.0, 1.0, 0.7) 
	_ColorContrast ("Color Contrast", float) = 2.5
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
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                half2 uv : TEXCOORD0;
            };

            float4 _Color;
            int _Cycles;
            float4 _RandomColor; // ("Color of Randoms", Color) = (0.035, 0.01, 0.0, 0.7)
            float _Random; // ("Random value", float) = 13.545317
            float _Periods; // ("Light impulse periods", float) = 0.01
            float _SinX; // ("Sin X", float) = 7.0
            float _SinY; // ("Sin Y", float) = 31.0
            float _ColIntensityMin; // ("Lower value of color Intensity", float) = 0.45
            float _ColIntensityMax; // ("Higher value of color Intensity", float) = 0.55
            float4 _ColorShape; // ("Color Shape", Color) = (1.0, 1.0, 0.7) 
            float _ColorContrast; // ("Color Contrast", float) = 2.
            
            float4 _MainTex_ST;
            
            v2f vert (appdata_t v)
            {
                v2f OUT;
                OUT.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
                OUT.uv = ComputeScreenPos(OUT.vertex);
                return OUT;
            }
            
            fixed4 frag (v2f IN) : SV_Target {            
                // vec2 pos = 256.0*fragCoord.xy/iResolution.x + iGlobalTime;
                float2 pos = 256.0*IN.uv;
                pos.x = pos.x * 1.77777777;

                float3 color = 0.0;
                for( int i = 0; i < _Cycles; i++ ) 
                {
                    float2 a = floor(pos);
                    float2 b = frac(pos);
                    
                    float4 w =
                    	frac(sin(a.x*_SinX + a.y*_SinY + _Periods * _Time) + _RandomColor * _Random);// randoms
                    // w = (1.0, 1.0, 1.0, 1.0);
                    color += w.xyz *												// color
                           smoothstep(_ColIntensityMin, _ColIntensityMax, w.w) *	// intensity
                           sqrt( 16.0*b.x*b.y*(1.0-b.x)*(1.0-b.y) );	// pattern
                    
                    pos /= 2.0; // lacunarity
                    color /= 2.0; // attenuate high frequencies
                }
                
                color = pow( _ColorContrast * color, _ColorShape );    // contrast and color shape
                
                return float4( color, 1.0 );
            }
        ENDCG
    }
}

}