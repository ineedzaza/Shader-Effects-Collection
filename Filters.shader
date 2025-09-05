Shader "Custom/FFmpegFiltersShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Hue("Hue Shift", Range(0,360)) = 0
        _Saturation("Saturation", Range(0,2)) = 1
        _Brightness("Brightness", Range(0,2)) = 1
        _Negate("Negate", Float) = 0
        _WaveAmount("Wave Amount", Range(0,0.1)) = 0
        _SwirlAngle("Swirl Angle", Range(-360,360)) = 0
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
            float4 _MainTex_ST;
            float _Hue;
            float _Saturation;
            float _Brightness;
            float _Negate;
            float _WaveAmount;
            float _SwirlAngle;
            float _LUTSize;

            struct appdata { float4 vertex : POSITION; float2 uv : TEXCOORD0; };
            struct v2f { float2 uv : TEXCOORD0; float4 vertex : SV_POSITION; };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            // Example: hue shift function
            float3 HueShift(float3 col, float hue)
            {
                float angle = hue / 360.0;
                float3 c = col;
                float3 K = float3(0.57735, 0.57735, 0.57735);
                float cosA = cos(angle * 6.28318); // 2pi
                float sinA = sin(angle * 6.28318);
                return c * cosA + cross(K, c) * sinA + K * dot(K, c) * (1 - cosA);
            }

            // Negate function
            float3 Negate(float3 col, float enable) { return enable > 0.5 ? 1-col : col; }

            // Wave distortion
            float2 Wave(float2 uv, float amount, float t)
            {
                uv.x += sin(uv.y * 6.28318 + t) * amount;
                uv.y += sin(uv.x * 6.28318 + t) * amount;
                return uv;
            }

            // Swirl distortion
            float2 Swirl(float2 uv, float2 center, float angle)
            {
                float2 offset = uv - center;
                float r = length(offset);
                float a = radians(angle) * exp(-r*5);
                float s = sin(a);
                float c = cos(a);
                return float2(offset.x*c - offset.y*s, offset.x*s + offset.y*c) + center;
            }

            fixed4 SampleLUT(float3 color)
            {
                float slice = color.b * (_LUTSize-1);
                float ySlice = floor(slice);
                float2 uv;
                uv.x = color.r * (_LUTSize-1)/_LUTSize + 0.5/_LUTSize;
                uv.y = color.g * (_LUTSize-1)/_LUTSize + 0.5/_LUTSize + ySlice/_LUTSize;
                return tex2D(_LUT, uv);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float t = _Time.y;

                // Apply wave
                uv = Wave(uv, _WaveAmount, t);

                // Apply swirl
                uv = Swirl(uv, float2(0.5,0.5), _SwirlAngle);

                // Sample texture
                fixed4 col = tex2D(_MainTex, uv);

                // Apply hue shift
                col.rgb = HueShift(col.rgb, _Hue);

                // Apply saturation and brightness
                col.rgb = pow(col.rgb, float3(1.0/_Saturation));
                col.rgb *= _Brightness;

                // Apply negate
                col.rgb = Negate(col.rgb, _Negate);

                // Apply LUT if provided
                col.rgb = SampleLUT(col.rgb).rgb;

                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
