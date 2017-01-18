Shader "_KTU/DiffuseSelectedDecal" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB)", 2D) = "white" {}
    _DecalTex ("Decal (RGBA)", 2D) = "white" {}
	
	_SelectionFactor ("SelectionFactor", float) = 1
	_InstantiationTime ("InstantiationTime", float) = 0
}
SubShader {
	Tags { "RenderType"="Opaque" }
	LOD 200

CGPROGRAM
#pragma surface surf Lambert vertex:vert addshadow

sampler2D _MainTex;
sampler2D _DecalTex;
fixed4 _Color;

struct Input {
	float2 uv_MainTex : TEXCOORD0;
    float2 uv_DecalTex :   TEXCOORD1;
};

//float _Amount;
float _InstantiationTime;

float InstantiationTimeFactor()
{
	float instantiationDuration = 100;
	return saturate(1 - (_Time.y - _InstantiationTime) / instantiationDuration);
}

void vert (inout appdata_full v) 
{
	//float scale = unity_Scale.w;
	float scale = 1 / length(_Object2World[0].xyz);
	
	float to = v.vertex.x + v.vertex.y + v.vertex.z;
	float f = sin(_Time.y * 8 + to * 4 / scale);	
	//float f = sin(_Time.y * 8 + to * 12);	
	f *= InstantiationTimeFactor();
	//v.vertex.xyz += normalize(v.normal) * 0.1 * f * scale;
	//v.vertex.xyz += normalize(v.vertex.xyz) * 0.12 * f * scale;
	
	float l = max(0.0001, length(v.vertex.xyz));
	v.vertex.xyz += v.vertex.xyz / l * 0.12 * f * scale;
	//v.vertex.xyz += normalize(v.normal) * 0.01 * f;
}

fixed _SelectionFactor;

void surf (Input IN, inout SurfaceOutput o) {
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	fixed4 d = tex2D (_DecalTex, IN.uv_DecalTex);

	o.Albedo = lerp(c, d, d.a);
	o.Alpha = c.a;
}
ENDCG
}

Fallback "VertexLit"
}
