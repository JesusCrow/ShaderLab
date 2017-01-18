//
// Function f(x)
// by Paulius Varna, 2017
//
Shader "_Varna/f(x)/PowerRandomHeights" {
Properties {
		_PowerLevel	("Power level", float) = 1
		_OffsetX	("X axis offset", float) = 0
		_OffsetY	("Y axis offset", float) = 0
		_Color		("Main Color", Color) = (1, 0, 0, 1)
		_Ycoff		("Coefficient of Y", float) = 1
		_Speedcoff	("Coefficient of Speed", float) = 1
	}
	SubShader {
		Tags {
			"Queue"="Background"
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
		float _Ycoff;
		float _Speedcoff;

		// Random function from "The Book of Shaders"
		float random(float2 st) { 
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

			_OffsetX = _OffsetX + _Time[1] * _Speedcoff;
			// _OffsetY = _OffsetY + _Time[1] * 0.6;
			
			// x function
			float x_Fun = abs(IN.uv.x + _OffsetX);
			x_Fun = (floor(2 * frac(0.5 * x_Fun))) - frac(x_Fun); 

			// y function
			float y_Fun = _OffsetY + pow(x_Fun, _PowerLevel);
			y_Fun = y_Fun * _Ycoff;
			// * random(float2(floor(IN.uv.x), 0.0))


			float3 color = _Color * step(IN.uv.y, y_Fun);
			float opacity = step(IN.uv.y, y_Fun);

			return float4(color, opacity);
		}

        ENDCG
    	}
	}
	Fallback "Unlit/Texture"
}