Shader "Custom/HueShiftShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Hue("Hue Shift", Range(0,360)) = 0
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
            float _Hue;

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

            // RGB -> HSV conversion
            float3 RGBtoHSV(float3 c)
            {
                float4 K = float4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
                float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
                float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

                float d = q.x - min(q.w, q.y);
                float e = 1e-10;
                float3 hsv;
                hsv.x = abs(q.z + (q.w - q.y) / (6.0 * d + e));
                hsv.y = d / (q.x + e);
                hsv.z = q.x;
                return hsv;
            }

            // HSV -> RGB conversion
            float3 HSVtoRGB(float3 c)
            {
                float3 rgb = clamp(abs(frac(c.x + float3(0, 2/3.0, 1/3.0))*6.0 - 3.0) - 1.0, 0.0, 1.0);
                return c.z * lerp(float3(1.0,1.0,1.0), rgb, c.y);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 texColor = tex2D(_MainTex, i.uv);
                float3 hsv = RGBtoHSV(texColor.rgb);
                hsv.x += _Hue / 360.0;  // shift hue
                hsv.x = frac(hsv.x);    // wrap around 0..1
                float3 rgb = HSVtoRGB(hsv);
                return float4(rgb, texColor.a);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
