Shader "PavelKouril/LowPoly Shader/LowPoly"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
		_Shininess ("Shininess", Float) = 10
	}
	SubShader
	{
		Tags {"RenderType" = "Opaque"}
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma target 5.0
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog

			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			uniform float4 _Color;
			uniform sampler2D _MainTex;
			uniform float _Shininess;

			struct v2g
			{
				float4 pos : SV_POSITION;
				float3 norm : NORMAL;
				float2 uv : TEXCOORD0;
				float3 vertex : TEXCOORD1;
				float3 vertexLighting : TEXCOORD2;
				half fogDepth: TEXCOORD3;
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
				float3 norm : NORMAL;
				float2 uv : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float3 vertexLighting : TEXCOORD2;
				LIGHTING_COORDS(3, 4)
				half fogDepth: TEXCOORD5;
			};

			v2g vert(appdata_full v)
			{
				v2g OUT;
				OUT.pos = UnityObjectToClipPos(v.vertex);
				OUT.norm = v.normal;
				OUT.uv = v.texcoord;
				OUT.vertex = v.vertex;

				float3 vertexLighting = float3(0, 0, 0);
				#ifdef VERTEXLIGHT_ON
				for (int index = 0; index < 4; index++)
				{
					float3 normalDir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
					float3 lightPosition = float3(unity_4LightPosX0[index], unity_4LightPosY0[index], unity_4LightPosZ0[index]);
					float3 vertexToLightSource = lightPosition - mul(unity_ObjectToWorld, v.vertex);
					float3 lightDir = normalize(vertexToLightSource);
					float distanceSquared = dot(vertexToLightSource, vertexToLightSource);
					float attenuation = 1.0 / (1.0 + unity_4LightAtten0[index] * distanceSquared);

					vertexLighting += attenuation * unity_LightColor[index].rgb * _Color.rgb * saturate(dot(normalDir, lightDir));
				}
				#endif
				OUT.vertexLighting = vertexLighting;

				OUT.fogDepth = length(UnityObjectToClipPos(v.vertex));
				#if defined(FOG_LINEAR)
					OUT.fogDepth = clamp(OUT.fogDepth * unity_FogParams.z + unity_FogParams.w, 0.0, 1.0);
				#elif defined(FOG_EXP)
					OUT.fogDepth = exp2(-(OUT.fogDepth * unity_FogParams.y));
				#elif defined(FOG_EXP2)
					OUT.fogDepth = exp2(-(OUT.fogDepth * unity_FogParams.y)*(OUT.fogDepth * unity_FogParams.y));
				#else
					OUT.fogDepth = 1.0;
				#endif

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
				OUT.vertexLighting = (IN[0].vertexLighting + IN[1].vertexLighting + IN[2].vertexLighting) / 3;
				OUT.posWorld = mul(unity_ObjectToWorld, (IN[0].vertex + IN[1].vertex + IN[2].vertex) / 3);

				OUT.pos = IN[0].pos;
				OUT.fogDepth = IN[0].fogDepth;
				TRANSFER_VERTEX_TO_FRAGMENT(OUT);
				triStream.Append(OUT);

				OUT.pos = IN[1].pos;
				OUT.fogDepth = IN[1].fogDepth;
				TRANSFER_VERTEX_TO_FRAGMENT(OUT);
				triStream.Append(OUT);

				OUT.pos = IN[2].pos;
				OUT.fogDepth = IN[2].fogDepth;
				TRANSFER_VERTEX_TO_FRAGMENT(OUT);
				triStream.Append(OUT);
			}

			half4 frag(g2f IN) : COLOR
			{
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - IN.posWorld.xyz);
				float3 normalDir = normalize(mul(float4(IN.norm, 0.0), unity_WorldToObject).xyz);
				float3 vertexToLight = _WorldSpaceLightPos0.w == 0 ? _WorldSpaceLightPos0.xyz : _WorldSpaceLightPos0.xyz - IN.posWorld.xyz;
				float3 lightDir = normalize(vertexToLight);

				float3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
				UNITY_LIGHT_ATTENUATION(atten, IN, IN.posWorld);
				float3 diffuseReflection = atten * _LightColor0.rgb * _Color.rgb * saturate(dot(normalDir, lightDir));

				float3 specularReflection = float3(0.0, 0.0, 0.0);
				if (dot(normalDir, lightDir) >= 0.0)
				{
					specularReflection = atten * _LightColor0.rgb * pow(max(0.0, dot(reflect(-lightDir, normalDir), viewDir)), _Shininess);
				}

				float4 colorTex = float4((IN.vertexLighting + ambientLight + diffuseReflection + specularReflection) * tex2D(_MainTex, IN.uv), 1);
				return lerp(unity_FogColor, colorTex, IN.fogDepth);
			}

			ENDCG
		}
		
		Pass
		{
			Tags {"LightMode" = "ForwardAdd"}
			Blend One One
			ZWrite Off

			CGPROGRAM

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#pragma multi_compile_fwdadd_fullshadows

			uniform float4 _Color;
			uniform sampler2D _MainTex;
			uniform float _Shininess;

			struct v2g
			{
				float3 norm : NORMAL;
				float3 vertex : TEXCOORD0;
				float3 uv : TEXCOORD1;
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
				float3 norm : NORMAL;
				float4 posWorld : TEXCOORD0;
				float3 uv : TEXCOORD1;
				LIGHTING_COORDS(3, 4)
			};

			// hack because TRANSFER_VERTEX_TO_FRAGMENT has harcoded requirement for 'v.vertex'
			struct unityTransferVertexToFragmentSucksHack
			{
				float4 vertex : SV_POSITION;
			};

			appdata_full vert(appdata_full v)
			{
				appdata_full OUT;
				OUT = v;
				return OUT;
			}

			[maxvertexcount(3)]
			void geom(triangle appdata_full IN[3], inout TriangleStream<g2f> triStream)
			{
				g2f OUT;
				OUT.norm = normalize((IN[0].normal + IN[1].normal + IN[2].normal) / 3);
				OUT.uv = (IN[0].texcoord + IN[1].texcoord + IN[2].texcoord) / 3;

				unityTransferVertexToFragmentSucksHack v;

				v.vertex = IN[0].vertex;
				OUT.pos = UnityObjectToClipPos(v.vertex);
				OUT.posWorld = mul(unity_ObjectToWorld, v.vertex);
				TRANSFER_VERTEX_TO_FRAGMENT(OUT);
				triStream.Append(OUT);

				v.vertex = IN[1].vertex;
				OUT.pos = UnityObjectToClipPos(v.vertex);
				OUT.posWorld = mul(unity_ObjectToWorld, v.vertex);
				TRANSFER_VERTEX_TO_FRAGMENT(OUT);
				triStream.Append(OUT);

				v.vertex = IN[2].vertex;
				OUT.pos = UnityObjectToClipPos(v.vertex);
				OUT.posWorld = mul(unity_ObjectToWorld, v.vertex);
				TRANSFER_VERTEX_TO_FRAGMENT(OUT);
				triStream.Append(OUT);
			}

			float4 frag(g2f IN) : COLOR
			{
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - IN.posWorld.xyz);
				float3 normalDir = normalize(mul(float4(IN.norm, 0.0), unity_WorldToObject).xyz);
				float3 vertexToLight = _WorldSpaceLightPos0.w == 0 ? _WorldSpaceLightPos0.xyz : _WorldSpaceLightPos0.xyz - IN.posWorld.xyz;
				float3 lightDir = normalize(vertexToLight);

				UNITY_LIGHT_ATTENUATION(atten, IN, IN.posWorld.xyz);

				float3 specularReflection = float3(0.0, 0.0, 0.0);
				if (dot(normalDir, lightDir) >= 0.0)
				{
					specularReflection = atten * _LightColor0.rgb * pow(max(0.0, dot(reflect(-lightDir, normalDir), viewDir)), _Shininess);
				}
				
				float3 diffuseReflection = atten * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDir, lightDir));
				float4 colorTex = tex2D(_MainTex, IN.uv);
				return float4((diffuseReflection + specularReflection) * colorTex, 1);
			}

			ENDCG
		}
	}
	
	Fallback "Standard"
}
