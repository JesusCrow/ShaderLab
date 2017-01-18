//
// Function f(x)
// by Paulius Varna, 2017
//
Shader "_Varna/f(x)/PowerMinCosPi" {
Properties {
		_PowerLevel	("Power level", float) = 1
		_OffsetX	("X axis offset", float) = 0
		_OffsetY	("Y axis offset", float) = 0
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

		// Variables
		float4 _Color;
		float _PowerLevel;
		float _OffsetX;
		float _OffsetY;
		float _Pi = 3.14;

        // Vertex to fragment function (Building our object)
		v2f vertexFunction(appData IN) {
			v2f OUT;

			OUT.position = mul(UNITY_MATRIX_MVP, IN.vertex);
			OUT.uv = mul(_Object2World, IN.vertex).xy; 

			return OUT;
		}

		// Fragment (pixel) function
		fixed4 fragmentFunction(v2f IN) : SV_Target {
			
			// x function
			float x_Fun = abs(IN.uv.x + _OffsetX);
			x_Fun = (floor(2 * frac(0.5 * x_Fun))) - frac(x_Fun);

			// prepare to empowered!
			float xp = max(0.0, abs(x_Fun) * 2 - 1);

			// y function
			float y_Fun = _OffsetY + 1.0 - pow(xp, _PowerLevel);


			float3 color = _Color * step(IN.uv.y, y_Fun);

			return float4(color, 1.0);
		}

        ENDCG
    	}
	}
	Fallback "Unlit/Texture"
}