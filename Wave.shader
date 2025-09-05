Shader "Custom/WavesShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _HorizontalWaves("Horizontal Waves", Range(0,6.284)) = 1.0
        _VerticalWaves("Vertical Waves", Range(0,6.284)) = 1.0
        _Amplitude("Amplitude", Range(0,0.1)) = 0.05
        _Speed("Speed", Range(0,5)) = 1.0
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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _HorizontalWaves;
            float _VerticalWaves;
            float _Amplitude;
            float _Speed;

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

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;

                // animate time
                float t = _Time.y * _Speed;

                // horizontal wave (displace x by sin)
                uv.x += sin(uv.y * _HorizontalWaves + t) * _Amplitude;

                // vertical wave (displace y by sin)
                uv.y += sin(uv.x * _VerticalWaves + t) * _Amplitude;

                // sample texture
                fixed4 col = tex2D(_MainTex, uv);
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
