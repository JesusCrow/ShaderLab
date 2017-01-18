//
// Pattern of squares with picked color
// by Paulius Varna
// at 2016-12-26 00:55
//
Shader ".Varna/Unlit/Pattern/Square/Color" {
Properties {
		_TileSize	("The Scale of Tiles", float) = 1
		_Color		("Main Color", Color) = (1, 0, 0, 1)
	}
	SubShader {
		Pass {
 
		CGPROGRAM

		#pragma vertex vertexFunction            
		#pragma fragment fragmentFunction

		struct appData {
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
			
		};  

		struct v2f {
			float4 position : SV_POSITION;
			float2 uv : TEXCOORD0;
		};

		// Variables START
		float4 _Color;
		float _TileSize;

		// Random function from "The Book of Shaders"
		float random (float2 st) { 
		    return frac(sin(dot(st.xy, float2(12.9898,78.233)))*43758.5453123);
		}

        // Vertex to fragment function (Building our object)
		v2f vertexFunction(appData IN) {
			v2f OUT;

			OUT.position = mul(UNITY_MATRIX_MVP, IN.vertex);
			OUT.uv = mul(_Object2World, IN.vertex).xy; 

			return OUT;
		}

		// Fragment (pixel) function
		fixed4 fragmentFunction(v2f IN) : SV_Target {

			// Set the scale and discard fractional part
			float2 ipos = floor(IN.uv * _TileSize);

			// Scale color darkness by random amount
			// within the floored area
			float3 color = _Color * random( ipos ); 

			return float4(color, 1.0);
		}

        ENDCG
    	}
	}
	Fallback "Unlit/Texture"
}