//
// Function f(x)
// by Paulius Varna, 2017
//
Shader "_Varna/f(x)/PowerCosPi" {
Properties {
		_PowerLevel	("Power level", float) = 1
		_OffsetX	("X axis offset", float) = 0
		_OffsetY	("Y axis offset", float) = 0
		_Width		("Width", float) = 1
		_Height		("Height", float) = 1
		_Color		("Main Color", Color) = (1, 0, 0, 1)
	}
	SubShader {
		Tags {
			"Queue"="Background+1"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
		}
		LOD 100
		
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha 

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
		float _Width;
		float _Height;
		float _Pi = 3.14;


        // Vertex to fragment function (Building our object)
		v2f vertexFunction(appData IN) {
			v2f OUT;

			OUT.position = mul(UNITY_MATRIX_MVP, IN.vertex);
			OUT.uv = IN.uv; 

			return OUT;
		}

		// Fragment (pixel) function
		fixed4 fragmentFunction(v2f IN) : SV_Target {

			IN.uv.x = IN.uv.x * _Width;
			IN.uv.y = IN.uv.y * _Height;
			
			// x function
			float x_Fun = abs(IN.uv.x + _OffsetX);
			// x_Fun = (floor(2 * frac(0.5 * x_Fun))) - frac(x_Fun);

			// prepare to empowered!
			float xp = cos(x_Fun);

			// y function
			float y_Fun = _OffsetY + pow(xp, _PowerLevel);


			float3 color = _Color * step(IN.uv.y, y_Fun);
			float opacity = step(IN.uv.y, y_Fun);

			return float4(color, opacity);
		}

        ENDCG
    	}
	}
}