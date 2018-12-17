Shader "Unlit/perturb"
{
	Properties
	{
        _MainTex ("Texture", 2D) = "white" {}
		_Perturb ("_Perturb", 2D) = "white" {}
        _PerturbScale("Perturb scale", Range(0,1)) = 1
        _MatCapTex("_MatCapTex", 2D) = "white" {}
        _ColorGradient("_ColorGradient", 2D) = "white" {}
        _Heightmap("_Heightmap", 2D) = "white" {}
        _Scale("Scale", Range(0.1, 20)) = 1
        _SpecularPower("Specular Pow", Range(0.1, 10)) = 1
        _SpecularStrength("Specular Strength", Range(0, 1)) = 0.8
        _FogPower("Fog Pow", Range(0.01, 1)) = 1
        _FogStrength("Fog Strength", Range(0, 2)) = 1
        

        
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Transparent"}
		LOD 100
//        Blend SrcAlpha OneMinusSrcAlpha
        Blend One OneMinusSrcAlpha
        ZWrite off
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
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
                float3 vertex_w_pos : TEXCOORD2;
			};

            sampler2D _MainTex;
			sampler2D _Perturb;
            sampler2D _MatCapTex;
            sampler2D _ColorGradient;
            sampler2D _Heightmap;

            float4 _MainTex_ST;
			float4 _Perturb_ST;
			float _PerturbScale;
            float _Scale;

            float3 _LightPosition;
            float _SpecularPower;
            float _SpecularStrength;
            float _FogPower;
            float _FogStrength;

			v2f vert (appdata v)
			{
				v2f o;

                float3 world_pos = float3(0,0,0);

                float3x3 inverse_v;

                inverse_v[0] = float3(UNITY_MATRIX_V[0][0],UNITY_MATRIX_V[0][1], UNITY_MATRIX_V[0][2]);
                inverse_v[1] = float3(UNITY_MATRIX_V[1][0],UNITY_MATRIX_V[1][1], UNITY_MATRIX_V[1][2]);
                inverse_v[2] = float3(UNITY_MATRIX_V[2][0],UNITY_MATRIX_V[2][1], UNITY_MATRIX_V[2][2]);

                float3 camera_dir = inverse_v[2];

                float3 right = normalize(cross(camera_dir, float3(0., 1., 0.)));
                float3 up = -normalize(cross(camera_dir, right));

                float2 dir = v.uv * 2.0 - 1.0;
                dir *= 0.5 * _Scale;
                world_pos += up * dir.y + right * dir.x;


                o.w_pos = mul(unity_ObjectToWorld, float4(float3(0,0,0), 1)).xyz;
                o.vertex_w_pos = mul(UNITY_MATRIX_MV,float4(world_pos, 1)).xyz;
                o.vertex = UnityObjectToClipPos(float4(world_pos, 1));
                o.uv = v.uv;
                return o;
			}

            float3 calculate_normal(float2 uv)
            {
                float tex_res = 256;
                float offset = 1.0/tex_res;


                float center = tex2D(_MainTex, uv).a;
                float right = tex2D(_MainTex, uv + float2(offset, 0)).a;
                float up = tex2D(_MainTex, uv + float2(0, offset)).a;

                float left = tex2D(_MainTex, uv - float2(offset, 0)).a;
                float down = tex2D(_MainTex, uv - float2(0, offset)).a;
                
                float dx = right - left;
                float dy = up - down;
                return normalize(float3(dx*2, -dy*2, 1));
            }

            float fresnel(float3 normal, float3 view_dir)
            {
                float n1 = 1.00029;
                float n2 = 1.33;
                float R0 = pow((n1 - n2)/(n1+n2), 2);
                return R0 + (1-R0)*pow(1-dot(normal, view_dir),5);
            }


			
			fixed4 frag (v2f i) : SV_Target
			{
                float perturb_w_scale = tex2D(_Perturb, i.w_pos.xz*10).x;
				// sample the texture
                float perturb_x = 1-tex2D(_Perturb, i.uv+float2(_Time.x+perturb_w_scale, -0.3 * _Time.x+perturb_w_scale)).x;
				float perturb_y = 1-tex2D(_Perturb, i.uv+float2(_Time.x*0.5+perturb_w_scale, 0.5 * _Time.x+0.9+perturb_w_scale)).y;
                float2 uv = i.uv * 2 - 1;
                float alpha = tex2D(_MainTex, uv).a;

                uv.x+=(perturb_x * 2 -1)* _PerturbScale * max(alpha,0.3)*perturb_w_scale;
                uv.y+=(perturb_y * 2 -1)* _PerturbScale * max(alpha,0.3)*perturb_w_scale;

                uv = uv * 0.5 + 0.5;

                float3 normal = calculate_normal(uv);

                float fresnel_value = 1-saturate(dot(normal, float3(0,0,1)));
//                return float4(normal * 0.5 + 0.5, 1.0);

//                float3 light_col = tex2D(_MatCapTex, normal.xy*0.5+0.5).xyz;
                float mask = tex2D(_MatCapTex, i.uv).a;

                float3 camera_dir = normalize(_WorldSpaceCameraPos - i.w_pos);
                float3 light_dir = normalize(_LightPosition - i.w_pos);
                float specular = dot(normalize(camera_dir+ light_dir), float3(0,1,0));
                specular = saturate(pow(specular, _SpecularPower));

                float3 gradient_col = tex2D(_ColorGradient, float2(i.uv.y,0));
                fixed4 col = tex2D(_MainTex, uv);
                col.rgb += _SpecularStrength * mask * specular;

                float d = saturate(-i.vertex_w_pos.z/20);
                //return fixed4(d,d,d,col.a);
                float3 fog_col = float3(84,118,179)/255;
                //return fixed4(d * fog_col*col.a,col.a);
                


//                return float4((col.rgb+fresnel_value*2*0)*col.a,col.a);
                float4 final_col = float4((col.rgb*gradient_col+(perturb_w_scale*2-1)*0.1)*col.a,col.a);
                //final_col.rgb += fog_col * d * _FogStrength *col.a * pow(specular, _FogPower);
                final_col.rgb += fog_col * _FogStrength *col.a * pow(specular, _FogPower);
                return final_col;

			}
			ENDCG
		}
	}
}
