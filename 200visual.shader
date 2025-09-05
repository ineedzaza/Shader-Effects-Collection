Shader "Custom/MultiEffectShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EffectType ("Effect Type", Range(0, 200)) = 0
        _EffectIntensity ("Intensity", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _EffectType;
            float _EffectIntensity;

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 ApplyEffect(float4 color, float effectType, float intensity, float2 uv)
            {
                // Example effects (expand to 200)
                if (effectType < 1)      // Grayscale
                {
                    float gray = dot(color.rgb, float3(0.3, 0.59, 0.11));
                    color.rgb = lerp(color.rgb, float3(gray, gray, gray), intensity);
                }
                else if (effectType < 2) // Invert
                {
                    color.rgb = lerp(color.rgb, 1.0 - color.rgb, intensity);
                }
                else if (effectType < 3) // Sepia
                {
                    float3 sepia = float3(
                        dot(color.rgb, float3(0.393, 0.769, 0.189)),
                        dot(color.rgb, float3(0.349, 0.686, 0.168)),
                        dot(color.rgb, float3(0.272, 0.534, 0.131))
                    );
                    color.rgb = lerp(color.rgb, sepia, intensity);
                }
                // ... continue adding more effects up to 200
                return color;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                col = ApplyEffect(col, _EffectType, _EffectIntensity, i.uv);
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
