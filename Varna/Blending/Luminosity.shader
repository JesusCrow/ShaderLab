
// Trying to fake Luminosity of Photoshop without HCL
// by Varna 2017

Shader "_Varna/Blending/Luminosity"
{
	Properties
	{
		_MainColor ( "Tint Color", Color ) = ( 1.0, 1.0, 1.0, 1.0 )
		_MainTex ( "Texture", 2D ) = "white" {}
		_Luma ( "Luma offset", Range(-0.5, 0.5)) = 0.0
		_Hue ( "Hue offset", Range(-0.5, 0.5)) = 0.0
		_Chroma ( "Chroma offset", Range(-0.5, 0.5)) = 0.0
	}
	
	SubShader
	{
		Tags {
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
		}

		ZWrite Off // should we write to the depth buffer?

		// Cull Front 	// Hide front while rendering
		// Cull Back 	// Hide back side while rendering // DEFAULT

		// Blend modes equation:
		//					    SrcFactor * fragment_output + DstFactor * pixel_color_in_framebuffer;
		// Blend {code for SrcFactor} {code for DstFactor}
		
		// Blend SrcAlpha OneMinusSrcAlpha // alpha blending
		// Blend One OneMinusSrcAlpha 	// premultiplied alpha blending
		// Blend One One					// additive
		// Blend SrcAlpha One			// additive blending
		// Blend OneMinusDstColor One    // soft additive
		// Blend DstColor Zero           // multiplicative
		Blend DstColor SrcColor       // 2x multiplicative
		// Blend Zero SrcAlpha			// multiplicative blending for attenuation by the fragment's alpha
		
		Pass
		{
Name "Luminosity"
CGPROGRAM
// #pragma exclude_renderers ps3 xbox360 flash
// #pragma fragmentoption ARB_precision_hint_fastest
#pragma vertex vertexFunction            
#pragma fragment fragmentFunction

#include "UnityCG.cginc"


// uniforms fixed(2-2), half(60k-60k), float(max)
fixed4 _MainColor;
sampler2D _MainTex;
float4 _MainTex_ST;
fixed _Luma;
fixed _Hue;
fixed _Chroma;

float HCLgamma = 3;
float HCLy0 = 100;
float HCLmaxL = 0.530454533953517; // == exp(HCLgamma / HCLy0) - 0.5
float PI = 3.1415926536;
 
float3 HUEtoRGB(in float H){
	float R = abs(H * 6 - 3) - 1;
	float G = 2 - abs(H * 6 - 2);
	float B = 2 - abs(H * 6 - 4);
	return saturate(float3(R,G,B));
}
float Epsilon = 1e-10;
float3 RGBtoHCV(in float3 RGB){
	// Based on work by Sam Hocevar and Emil Persson
	float4 P = (RGB.g < RGB.b) ? float4(RGB.bg, -1.0, 2.0/3.0) : float4(RGB.gb, 0.0, -1.0/3.0);
	float4 Q = (RGB.r < P.x) ? float4(P.xyw, RGB.r) : float4(RGB.r, P.yzx);
	float C = Q.x - min(Q.w, Q.y);
	float H = abs((Q.w - Q.y) / (6 * C + Epsilon) + Q.z);
	return float3(H, C, Q.x);
}
float3 HSVtoRGB(in float3 HSV){
	float3 RGB = HUEtoRGB(HSV.x);
	return ((RGB - 1) * HSV.y + 1) * HSV.z;
}
float3 HSLtoRGB(in float3 HSL){
	float3 RGB = HUEtoRGB(HSL.x);
	float C = (1 - abs(2 * HSL.z - 1)) * HSL.y;
	return (RGB - 0.5) * C + HSL.z;
}
// The weights of RGB contributions to luminance.
// Should sum to unity.
float3 HCYwts = float3(0.299, 0.587, 0.114);
float3 HCYtoRGB(in float3 HCY){
	float3 RGB = HUEtoRGB(HCY.x);
	float Z = dot(RGB, HCYwts);
	if (HCY.z < Z)
	{
	    HCY.y *= HCY.z / Z;
	}
	else if (Z < 1)
	{
	    HCY.y *= (1 - HCY.z) / (1 - Z);
	}
	return (RGB - Z) * HCY.y + HCY.z;
}
float3 HCLtoRGB(in float3 HCL){
	float3 RGB = 0;
	if (HCL.z != 0){
		float H = HCL.x;
		float C = HCL.y;
		float L = HCL.z * HCLmaxL;
		float Q = exp((1 - C / (2 * L)) * (HCLgamma / HCLy0));
		float U = (2 * L - C) / (2 * Q - 1);
		float V = C / Q;
		float T = tan((H + min(frac(2 * H) / 4, frac(-2 * H) / 8)) * PI * 2);
		H *= 6;
		if (H <= 1)
		{
		RGB.r = 1;
		RGB.g = T / (1 + T);
		}
		else if (H <= 2)
		{
		RGB.r = (1 + T) / T;
		RGB.g = 1;
		}
		else if (H <= 3)
		{
		RGB.g = 1;
		RGB.b = 1 + T;
		}
		else if (H <= 4)
		{
		RGB.g = 1 / (1 + T);
		RGB.b = 1;
		}
		else if (H <= 5)
		{
		RGB.r = -1 / T;
		RGB.b = 1;
		}
		else
		{
		RGB.r = 1;
		RGB.b = -T;
		}
		RGB = RGB * V + U;
	}
	return RGB;
}
float3 RGBtoHSV(in float3 RGB){
	float3 HCV = RGBtoHCV(RGB);
	float S = HCV.y / (HCV.z + Epsilon);
	return float3(HCV.x, S, HCV.z);
}
float3 RGBtoHSL(in float3 RGB){
	float3 HCV = RGBtoHCV(RGB);
	float L = HCV.z - HCV.y * 0.5;
	float S = HCV.y / (1 - abs(L * 2 - 1) + Epsilon);
	return float3(HCV.x, S, L);
}
float3 RGBtoHCY(in float3 RGB){
	// Corrected by David Schaeffer
	float3 HCV = RGBtoHCV(RGB);
	float Y = dot(RGB, HCYwts);
	float Z = dot(HUEtoRGB(HCV.x), HCYwts);
	if (Y < Z)
	{
		HCV.y *= Z / (Epsilon + Y);
	}
	else
	{
		HCV.y *= (1 - Z) / (Epsilon + 1 - Y);
	}
	return float3(HCV.x, HCV.y, Y);
}
float3 RGBtoHCL(in float3 RGB){
	float3 HCL;
	float H = 0;
	float U = min(RGB.r, min(RGB.g, RGB.b));
	float V = max(RGB.r, max(RGB.g, RGB.b));
	float Q = HCLgamma / HCLy0;
	HCL.y = V - U;
	if (HCL.y != 0){
		H = atan2(RGB.g - RGB.b, RGB.r - RGB.g) / PI;
		Q *= U / V;
	}
	Q = exp(Q);
	HCL.x = frac(H / 2 - min(frac(H), frac(-H)) / 6);
	HCL.y *= Q;
	HCL.z = lerp(-U, V, Q) / (HCLmaxL * 2);
	return HCL;
}


struct appData
{
	float4 vertex 		:	POSITION; // position (in object coordinates, i.e. local or model coordinates)
	// float4 tangent 		:	TANGENT;  // vector orthogonal to the surface normal
	// float3 normal 		:	NORMAL; // surface normal vector (in object coordinates; usually normalized to unit length)
	float4 texcoord 	:	TEXCOORD0;  // 0th set of texture coordinates (a.k.a. “UV”; between 0 and 1)
	// float4 texcoord1 	:	TEXCOORD1; // 1st set of texture coordinates  (a.k.a. “UV”; between 0 and 1)
	// fixed4 color 		:	COLOR; // vertex color
};


struct v2f
{
	float4	position 	: SV_POSITION;
    // fixed4	color 	: COLOR0;
    float4	uv 			: TEXCOORD0;
};


v2f vertexFunction( appData IN )
{
	v2f OUT;

	OUT.position = mul( UNITY_MATRIX_MVP, IN.vertex );

	OUT.uv = IN.texcoord;

	// Vertex distortion
	// IN.vertex.x += _SinTime.w * IN.vertex.y;
	


	// OUT.uv = TRANSFORM_TEX(IN.texcoord, _MainTex);
	// OUT.color = TRANSFORM_TEX(IN.texcoord, _MainTex);
	// OUT.color = tex2D(_MainTex, IN.texcoord);
	
	
	
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
	float4 	colorBG		= _MainColor;
	float4 	colorFG		= tex2D(_MainTex, IN.uv);
	float3 	HC 			= RGBtoHCV(colorBG.xyz);
	float3 	L 			= RGBtoHSL(colorFG.xyz);
	L.z 				= L.z + _Luma;
	HC.xy 				= HC.xy + fixed2(_Hue, _Chroma);
	float3 	colorHCL 	= float3(HC.x, HC.y, L.z);

	half4 	color 		= half4(HSLtoRGB(colorHCL), 1.0);
	return color;
}

ENDCG
		} // end Pass
	} // end SubShader
	
	FallBack "Diffuse"
}