// rework of https://github.com/prime31/UnityCgShaderTutorials/blob/master/Assets/Lesson2/ColorDebug.shader
Shader "_Varna/ShaderDebug"
{
	Properties
	{
		_Color ( "Tint Color", Color ) = ( 1.0, 1.0, 1.0, 1.0 )
		_MainTex ( "Texture", 2D ) = "white" {}
	}
	
	SubShader
	{
		Tags {
			"Queue"="Background"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			// "PreviewType"="Plane"
		}

		ZWrite Off // should we write to the depth buffer?

		// Cull Front 	// Hide front while rendering
		// Cull Back 	// Hide back side while rendering // DEFAULT

		// Blend modes equation:
		//					    SrcFactor * fragment_output + DstFactor * pixel_color_in_framebuffer;
		// Blend {code for SrcFactor} {code for DstFactor}
		
		Blend SrcAlpha OneMinusSrcAlpha // alpha blending
		//Blend One OneMinusSrcAlpha 	// premultiplied alpha blending
		//Blend One One					// additive
		//Blend SrcAlpha One			// additive blending
		//Blend OneMinusDstColor One    // soft additive
		//Blend DstColor Zero           // multiplicative
		//Blend DstColor SrcColor       // 2x multiplicative
		//Blend Zero SrcAlpha			// multiplicative blending for attenuation by the fragment's alpha
		
		Pass
		{
CGPROGRAM
#pragma exclude_renderers ps3 xbox360 flash
#pragma fragmentoption ARB_precision_hint_fastest
#pragma vertex vertexFunction            
#pragma fragment fragmentFunction

#include "UnityCG.cginc"


// uniforms fixed(2-2), half(60k-60k), float(max)
uniform fixed4 _Color;


struct appData
{
	float4 vertex :		POSITION; // position (in object coordinates, i.e. local or model coordinates)
	float4 tangent :	TANGENT;  // vector orthogonal to the surface normal
	float3 normal :		NORMAL; // surface normal vector (in object coordinates; usually normalized to unit length)
	float4 texcoord :	TEXCOORD0;  // 0th set of texture coordinates (a.k.a. “UV”; between 0 and 1)
	float4 texcoord1 :	TEXCOORD1; // 1st set of texture coordinates  (a.k.a. “UV”; between 0 and 1)
	fixed4 color :		COLOR; // vertex color
};


struct v2f
{
	float4 pos : SV_POSITION;
    float4 color : COLOR0;
};


v2f vertexFunction( appData IN )
{
	v2f OUT;

	// Vertex distortion
	// IN.vertex.x += _SinTime.w * IN.vertex.y;

	OUT.pos = mul( UNITY_MATRIX_MVP, IN.vertex );
	OUT.color = _Color;
	
	
	
	// debug: uncomment the desired item to debug then return IN.color directly in the fragment shader
	// OUT.color = IN.texcoord;
	// OUT.color = IN.texcoord1;
	// OUT.color = IN.vertex;
	// OUT.color = IN.vertex + float4( 0.5, 0.5, 0.5, 0.0 ); // we add 0.5's to offset if the model verts go from -0.5 - 0.5
	// OUT.color = IN.tangent;
	// OUT.color = float4( IN.normal * 0.5 + 0.5, 1.0 ); // scale and bias the normal to get it in the range of 0 - 1
	// OUT.color = IN.color; // vertex colors
	
    
	return OUT;
}


half4 fragmentFunction( v2f IN ) : COLOR
{
	return IN.color;
}

ENDCG
		} // end Pass
	} // end SubShader
	
	FallBack "Diffuse"
}