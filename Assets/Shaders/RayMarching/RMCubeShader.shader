Shader "Unlit/RMCubeShader"
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


            #include "UnityCG.cginc"

            #define MAX_STEPS 100
            #define MAX_DIST 100
            #define SURF_DIST 1e-3

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 ro : TEXCOORD1;
                float3 hitPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.ro = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
                o.hitPos = v.vertex;
                return o;
            }

            float GetDist(float3 p){
                float d = length(p) - .5;
                d = length(float2(length(p.xz) - .5, p.y)) - .1;
                return d;
            }

            //distance to the scene (depth along the viewing ray)
            float Raymarch(float3 ro, float3 rd) {
                float d0 = 0;
                float dS;

                for (int i = 0; i < MAX_STEPS; i++){
                    float3 p = ro + d0 * rd;
                    dS = GetDist(p);
                    d0 += dS;
                    if (dS < SURF_DIST || d0 > MAX_DIST) break;
                }

                return d0;
            }

            float3 GetNormal(float3 p){
                float2 e = float2(1e-2, 0);
                float3 n = GetDist(p) - float3(
                    GetDist(p-e.xyy),
                    GetDist(p-e.yxy),
                    GetDist(p-e.yyx)
                    );

                return normalize(n);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv - .5; 
                float3 ro = i.ro;
                float3 rd = normalize(i.hitPos - ro);

                float d = Raymarch(ro, rd);
                fixed4 tex = tex2D(_MainTex, i.uv);
                fixed4 col = 0;
                float m = dot(uv, uv);

                if (d < MAX_DIST){
                    float3 p = ro + rd * d;
                    float3 n = GetNormal(p);
                    col.rgb = n;
                }

                col = lerp(col, tex, smoothstep(.1, .2, m));
                return col;
            }
            ENDCG
        }
    }
}
