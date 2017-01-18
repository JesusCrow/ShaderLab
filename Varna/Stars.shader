//
// inspired by urraka at https://www.shadertoy.com/view/lsfGWH
// Stars (pixels) at random world positions
// by Paulius Varna, 2017
//
Shader "_Varna/Unlit/Stars" {
Properties {
		_Concentration	("Concentration of stars", Range (0.0, 1.0)) = 0.996
		_OffsetX		("X axis offset", float) = 	0
		_OffsetY		("Y axis offset", float) = 	0
		_Color			("Main Color", Color) = 	(1, 0, 0, 1)
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
float _Concentration;
float _OffsetX;
float _OffsetY;

// Random function from "The Book of Shaders"
float random(float2 st) { 
    return frac(sin(dot(st.xy, float2(12.9898,78.233)))*43758.5453123);
}

// Vertex to fragment function (Building our object)
v2f vertexFunction(appData IN) {
	v2f OUT;

	OUT.position = mul(UNITY_MATRIX_MVP, IN.vertex);
	OUT.uv = IN.uv;

	return OUT;
}

// Fragment (pixel) function
fixed4 fragmentFunction(v2f IN) : SV_Target {
	float r = random(IN.uv);

	// pulsating by sin(), 25% brightness of a pixel
	float shiny = 0.25 * sin(_Time.x * 72.357 * r + 2357.2357 * r);
	float3 color = r * (shiny + 0.75);
	
	// using step(), to pick pixel by _Concentration ratio
	return float4(color *  _Color.xyz *step(_Concentration, r), 1.0);
}

        ENDCG
    	}
	}
	Fallback "Unlit/Color"
}