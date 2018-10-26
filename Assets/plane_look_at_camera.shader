// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/plane_look_at_camera"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Scale("Scale", Range(0.1, 20)) = 1
    }
    SubShader
    {
        

//        Pass
//        {
//            Tags { "RenderType"="Transparent" "RenderQueue"="Transparent"}
//            LOD 100
//            Blend One One
//            BlendOp Max
//            ZWrite off
//            CGPROGRAM
//            #pragma vertex vert
//            #pragma fragment frag
//            // make fog work
//            
//            #include "UnityCG.cginc"
//
//            struct appdata
//            {
//                float4 vertex : POSITION;
//                float2 uv : TEXCOORD0;
//            };
//
//            struct v2f
//            {
//                float2 uv : TEXCOORD0;
//                float4 vertex : SV_POSITION;
//            };
//
//            sampler2D _MainTex;
//            float4 _MainTex_ST;
//            float _Scale;
//            
//            v2f vert (appdata v)
//            {
//                v2f o;
//
//                float3 world_pos = float3(0,0,0);
//
//                float3x3 inverse_v;
//
//                inverse_v[0] = float3(UNITY_MATRIX_V[0][0],UNITY_MATRIX_V[0][1], UNITY_MATRIX_V[0][2]);
//                inverse_v[1] = float3(UNITY_MATRIX_V[1][0],UNITY_MATRIX_V[1][1], UNITY_MATRIX_V[1][2]);
//                inverse_v[2] = float3(UNITY_MATRIX_V[2][0],UNITY_MATRIX_V[2][1], UNITY_MATRIX_V[2][2]);
//
//                float3 camera_dir = inverse_v[2];
//
//                float3 right = normalize(cross(camera_dir, float3(0., 1., 0.)));
//                float3 up = -normalize(cross(camera_dir, right));
//
//                float2 dir = v.uv * 2.0 - 1.0;
//                dir *= 0.5 * _Scale;
//                world_pos += up * dir.y + right * dir.x;
//
//
//                o.vertex = mul(UNITY_MATRIX_MVP, float4(world_pos, 1));
//                o.uv = v.uv;
//                return o;
//            }
//            
//            fixed4 frag (v2f i) : SV_Target
//            {
//                float4 col = tex2D(_MainTex, i.uv);
//                if(col.a < 0.65)
//                    discard;
//                col.rgb *= col.a;
//                return col;
//            }
//            ENDCG
//        }



        Pass
        {
            Tags { "RenderType"="Transparent" "RenderQueue"="Transparent"}
            LOD 100
            Blend SrcAlpha OneMinusSrcAlpha
        
//            Blend One One
//            BlendOp Max
            ZWrite off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Scale;
            
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


                o.vertex = UnityObjectToClipPos(float4(world_pos, 1));
                o.uv = v.uv;
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                return float4(col.rgb * col.a, col.a);
            }
            ENDCG
        }
    }
}
