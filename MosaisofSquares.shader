Shader "Custom/Unlit/MosaicSquares" {
Properties {
		_BlocksX("Number of Blocks at X", float) = 5
		_BlocksY("Number of Blocks at Y", float) = 5
	}
	SubShader {
		Pass {
 
		CGPROGRAM

		#pragma vertex vertexFunction            
		#pragma fragment fragmentFunction

		// Getting required data
		struct appData {
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0; // texture coordinate
			
		};  

		// Getting required data
		struct v2f {
			float4 position : SV_POSITION;
			float2 uv : TEXCOORD0; // texture coordinate
		};

		// Reimporting variables
		float4 _Color;
		float _BlocksX;
		float _BlocksY;

		float random (float2 st) { 
		    return frac(sin(dot(st.xy, float2(12.9898,78.233)))*43758.5453123);
		}

        // Vertex to fragment function (Building our object)
		v2f vertexFunction(appData IN) {
			v2f OUT;

			OUT.position = mul(UNITY_MATRIX_MVP, IN.vertex);
			OUT.uv = IN.uv;

			return OUT;
		}

		// Coloring fragment
		fixed4 fragmentFunction(v2f IN) : SV_Target {

			// get the integer coords
			float2 ipos = floor(IN.uv * float2(_BlocksX, _BlocksY));

			// Assign a random value based on the integer coord
			float3 color = float3(random( ipos ), random( ipos ), random( ipos )); 

			return float4(color, 1.0);
		}

        ENDCG
    	}
	}
	Fallback "Unlit/Texture"
}