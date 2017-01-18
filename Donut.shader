Shader "Custom/Unlit/Donut" {
Properties {
		_MainTex ("RGBA Texture Image", 2D) = "red" {}
		_RotationSpeed ("Rotation Speed", Float) = 2.0

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
		sampler2D _MainTex;
		float4 _Color;
		float _RotationSpeed;


        // Vertex to fragment function (Building our object)
		v2f vertexFunction(appData IN) {
			v2f OUT;
			OUT.position = mul(UNITY_MATRIX_MVP, IN.vertex);

			// OUT.uv.xy = IN.uv.xy - 0.5;
			// float s = sin ( _RotationSpeed * _Time );
			// float c = cos ( _RotationSpeed * _Time );
			// float2x2 rotationMatrix = float2x2( c, -s, s, c);
			// rotationMatrix *=0.5;
			// rotationMatrix +=0.5;
			// rotationMatrix = rotationMatrix * 2-1;
			// OUT.uv.xy = mul ( OUT.uv.xy, rotationMatrix );
			// OUT.uv.xy += 0.5;
			OUT = IN;

			return OUT;
		}

		// Coloring fragment
		fixed4 fragmentFunction(v2f IN) : SV_Target {

			float4 textureColor = tex2D(_MainTex, IN.uv);
			_Color = textureColor;

			return _Color;
		}

        ENDCG
    	}
	}
	Fallback "Unlit/Texture"
}