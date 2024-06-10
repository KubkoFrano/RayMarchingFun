Shader "Unlit/PlaneUnlitShader"
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            //vertex shader
            v2f vert (appdata v)
            {
                v2f o;

                v.vertex.y += sin(v.vertex.x + _Time.y) * .3;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            //fragment shader
            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv - 5;
                float a = _Time.y;
                float2 p = float2(sin(a), cos(a));

                float2 distort = uv - p;

                float d = length(distort);
                float m = smoothstep(.5, .1, d);
                distort = distort * 20 * m;


                fixed4 col = tex2D(_MainTex, i.uv + distort);
                
                return col;
            }
            ENDCG
        }
    }
}
