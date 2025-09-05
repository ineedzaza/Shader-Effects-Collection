Shader "Custom/SwirlShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Center ("Swirl Center", Vector) = (0.5,0.5,0,0)
        _Angle ("Swirl Angle", Range(-360,360)) = 0
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
            float4 _Center;
            float _Angle;

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
                float2 center = _Center.xy;

                // vector from center
                float2 offset = uv - center;
                float dist = length(offset);

                // swirl factor decreases with distance (optional)
                float swirlAmount = radians(_Angle) * exp(-dist * 5.0); 

                // apply rotation
                float sinA = sin(swirlAmount);
                float cosA = cos(swirlAmount);
                float2 rotated;
                rotated.x = offset.x * cosA - offset.y * sinA;
                rotated.y = offset.x * sinA + offset.y * cosA;

                uv = rotated + center;

                // sample texture
                fixed4 col = tex2D(_MainTex, uv);
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
