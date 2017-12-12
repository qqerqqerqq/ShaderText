// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/Wang/LigthModel"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_SurfaceColor("自发光颜色", Color) = (1,1,1,1)   
		_SurfaceEX("自发光系数", Float) = 1
		_AmbientEX("环境光反射系数", Float) = 1
		_DiffuseEX("漫反射系数", Float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"  

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 time : POSITION;
				float4 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float _SurfaceEX;
			float _AmbientEX;
			float _DiffuseEX;
			float4 _SurfaceColor;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				UNITY_TRANSFER_FOG(o,o.vertex);
				float addPos = 0.5*(sin(_Time + (o.uv.y)) + 1);
				o.vertex.x *= addPos;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				UNITY_APPLY_FOG(i.fogCoord, col);
				//fixed4 Surface = col*_SurfaceColor*_SurfaceEX; //自发光颜色
				//fixed4 Ambient = col*_AmbientEX*_LightColor0.rgba; //环境光反射
				fixed4 Diffuse = col*_DiffuseEX*_LightColor0.rgba*saturate(dot(worldNormal, worldLightDir)); //漫反射
				//col = Surface + Ambient + Diffuse;// +Diffuse;
				col = Diffuse;

				return col;
			}
			ENDCG
		}
	}
}
