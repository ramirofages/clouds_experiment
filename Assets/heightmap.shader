Shader "Unlit/heightmap"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
                float3 w_pos : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.w_pos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

            float3 sample_heightmap_normal(float2 uv)
            {
                float tex_res = 512;
                float offset = 4/512.0;

                float center = tex2D(_MainTex, uv).r;
                float right = tex2D(_MainTex,   uv + float2(offset, 0)).r;
                float up = tex2D(_MainTex,      uv + float2(0, offset)).r;

                float left = tex2D(_MainTex, uv - float2(offset, 0)).r;
                float down = tex2D(_MainTex, uv - float2(0, offset)).r;
                
                float dx = right - left;
                float dy = up - down;

//                return normalize(cross(normalize(float3(dx,2,0)), normalize(float3(0,2,dy))));
//                return cross(normalize(float3(dx,0,0)), normalize(float3(0, dy, 0)));
                return normalize(float3(dx,dy,center*center));

//                return normalize(cross(float3(2,dx,0), float3(0, dy, 2)));

                
//                return normalize(float3(dx,sqrt(1 - dx*dx - dy*dy),dy));

            }
			
			fixed4 frag (v2f i) : SV_Target
			{
//                return tex2D(_MainTex, i.w_pos.xz/10);
				return fixed4(sample_heightmap_normal(i.w_pos.xz/10)*0.5+0.5,1);
			}
			ENDCG
		}
	}
}
