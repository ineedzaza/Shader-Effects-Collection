Shader "Custom/LUTShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _LUT("LUT Texture", 2D) = "white" {}
        _LUTSize("LUT Size", Float) = 32
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
            sampler2D _LUT;
            float _LUTSize;
            float4 _MainTex_ST;

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

            fixed4 SampleLUT(float3 color)
            {
                // Convert RGB to LUT UV coordinates
                float sliceSize = 1.0 / _LUTSize;
                float slicePixel = sliceSize / _LUTSize;
                float z = color.b * (_LUTSize - 1.0);
                float ySlice = floor(z);
                float yOffset = (z - ySlice);
                
                float2 uv;
                uv.x = color.r * (_LUTSize - 1.0) / _LUTSize + 0.5 / _LUTSize;
                uv.y = color.g * (_LUTSize - 1.0) / _LUTSize + 0.5 / _LUTSize + ySlice / _LUTSize;
                
                // Sample LUT texture
                fixed4 lutColor = tex2D(_LUT, uv);
                return lutColor;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 lutColor = SampleLUT(col.rgb);
                return fixed4(lutColor.rgb, col.a);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
