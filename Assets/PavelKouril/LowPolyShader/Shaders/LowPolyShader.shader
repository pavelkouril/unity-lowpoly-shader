Shader "Pavel Kouril/LowPoly"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
	}
		SubShader
	{

		Tags{ "RenderType" = "Opaque" }
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			Tags { "LightMode" = "ForwardBase"}

			CGPROGRAM

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			uniform float4 _Color;
			uniform sampler2D _MainTex;

			struct v2g
			{
				float4 pos : SV_POSITION;
				float3 norm : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
				float3 norm : NORMAL;
				float2 uv : TEXCOORD0;
				float3 center : TEXCOORD1;
				LIGHTING_COORDS(3, 4)
			};

			v2g vert(appdata_full v)
			{
				v2g OUT;
				OUT.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				OUT.norm = v.normal;
				OUT.uv = v.texcoord;
				return OUT;
			}

			[maxvertexcount(3)]
			void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream)
			{
				float3 v0 = IN[0].pos.xyz;
				float3 v1 = IN[1].pos.xyz;
				float3 v2 = IN[2].pos.xyz;

				g2f OUT;
				OUT.norm = normalize(IN[0].norm + IN[1].norm + IN[2].norm);
				OUT.uv = (IN[0].uv + IN[1].uv + IN[2].uv) / 3;
				OUT.center = (v0 + v1 + v2) / 3.0;

				OUT.pos = IN[0].pos;
				TRANSFER_VERTEX_TO_FRAGMENT(OUT);
				triStream.Append(OUT);

				OUT.pos = IN[1].pos;
				TRANSFER_VERTEX_TO_FRAGMENT(OUT);
				triStream.Append(OUT);

				OUT.pos = IN[2].pos;
				TRANSFER_VERTEX_TO_FRAGMENT(OUT);
				triStream.Append(OUT);
			}

			half4 frag(g2f IN) : COLOR
			{
				float3 normalDir = normalize(mul(float4(IN.norm, 0.0), unity_WorldToObject).xyz);
				float3 viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, float4(IN.center, 0.0)).xyz);
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

				float3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
				float3 diffuseReflection = LIGHT_ATTENUATION(IN) * _LightColor0.rgb * _Color.rgb * saturate(dot(normalDir, lightDir));

				float4 colorTex = tex2D(_MainTex, IN.uv);
				return float4((ambientLight + diffuseReflection) * colorTex, 1);
			}

				ENDCG

			}
	}
		FallBack "Diffuse"
}