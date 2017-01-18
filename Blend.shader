Shader "Custom/Unlit/Blend" {
   Properties {
      _MainTex ("RGBA Texture Image", 2D) = "white" {} 
	  _DecalTex ("RGBA Decal Image", 2D) = "white" {}
      _Blend("Blend", float) = 0.1
   }
   SubShader {
      Pass {

         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
 
         uniform sampler2D _MainTex;    
		 uniform sampler2D _DecalTex;    
         uniform float _Blend;
 
         struct vertexInput {
            float4 vertex : POSITION;
            float4 texcoord : TEXCOORD0;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 tex : TEXCOORD0;
         };
 
         vertexOutput vert(vertexInput input) 
         {
            vertexOutput output;
 
            output.tex = input.texcoord;
            output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
            return output;
         }

         float4 frag(vertexOutput input) : COLOR
         {
            float4 textureColor = tex2D(_MainTex, input.tex.xy);
			float4 decalColor = tex2D(_DecalTex, input.tex.xy);
            return lerp(textureColor, decalColor, abs(sin(_Time[1])));
         }
 
         ENDCG
      }
   }
   Fallback "Unlit/Texture"
}