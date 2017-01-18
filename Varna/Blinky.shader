Shader "_Varna/Unlit/Blinky" {
Properties {
	_Color1 ("Main Color", Color) = (0,0,0,1)
	_Color2 ("Secondary Color", Color) = (1,0,0,1)
	_Speed("Speed", float) = 2
	_PointsLeft("Points Left", int) = 4
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

            struct appdata_t {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

			struct v2f {
			    float4 vertex : SV_POSITION;
			    half2 texcoord : TEXCOORD0;
			};

			float4 _Color1;
			float4 _Color2;
			float _Speed;
			int _PointsLeft;
            
            float4 _MainTex_ST;
            
			v2f vert (appdata_t IN)
			{
			    v2f OUT;
			    OUT.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
			    OUT.texcoord = IN.texcoord;
			    return OUT;
			}

			fixed4 frag (v2f i) : SV_Target {
			float3 diff = float3(_Color1.rgb - _Color2.rgb);
			float3 color = _Color1 - diff * abs(sin(_Time[1] * _Speed / _PointsLeft));
			return fixed4(color, step(1, _PointsLeft));
			}
        ENDCG
    }
}

}