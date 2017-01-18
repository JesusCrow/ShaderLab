Shader "_KTU/Diffuse" {
   Properties {
      _MainTex ("RGBA Texture Image", 2D) = "white" {} 
   }
   SubShader {
	  Tags { "LightMode" = "ForwardBase" }
      Pass {

         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
 
         uniform sampler2D _MainTex;
		 uniform fixed4 _LightColor0;   
 
         struct vertexInput {
            float4 vertex : POSITION;
			float3 normal : NORMAL;
            float4 texcoord : TEXCOORD0;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
			float4 color : COLOR0;
            float4 tex : TEXCOORD0;
         };
 
         vertexOutput vert(vertexInput input) 
         {
            vertexOutput output;
 
            output.tex = input.texcoord;
            output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
			
			float3 normalDirection = normalize( mul( float4( input.normal, 1.0 ), _World2Object ).xyz );
			float3 lightDirection = normalize( _WorldSpaceLightPos0.xyz );
			float ndotl = dot( normalDirection, lightDirection );
			float3 diffuse = _LightColor0.xyz * max( 0.0, ndotl );
	
			output.color = half4( diffuse, 1.0 );
            return output;
         }

         float4 frag(vertexOutput input) : COLOR
         {
            float4 textureColor = tex2D(_MainTex, input.tex.xy) * input.color;  
            return textureColor;
         }
 
         ENDCG
      }
   }
   Fallback "Diffuse"
}