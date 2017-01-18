Shader "Custom/Noob" {
	Properties {
		_MainTexture ("RGBA Texture Image", 2D) = "red" {}
		_Color ("Color", Color) = (1,1,1,1)

		_DissolveTexture ("Dissolve Texture", 2D) = "white" {}
		_DissolveAmount ("Dissolve Amount", Range(0, 1)) = 1
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
		sampler2D _MainTexture;
		float4 _Color;

		sampler2D _DissolveTexture;
		float _DissolveAmount;

        // Vertex to fragment function (Building our object)
		v2f vertexFunction(appData IN) {
			v2f OUT;

			// Time is float4 (xyzw) difference in speed
			// IN.vertex.xyz += IN.normal.xyz * _ExtrudeAmount * _Time.y;

			OUT.position = mul(UNITY_MATRIX_MVP, IN.vertex);
			OUT.uv = IN.uv;

			return OUT;
		}

		// Coloring fragment
		fixed4 fragmentFunction(v2f IN) : SV_Target {
			float4 textureColor = tex2D(_MainTexture, IN.uv);
			float4 dissolveColor = tex2D(_DissolveTexture, IN.uv);

			clip(dissolveColor.rgb - _DissolveAmount);

			return textureColor * _Color;
		}

        ENDCG
    	}
	}
	Fallback "Unlit/Texture"
}