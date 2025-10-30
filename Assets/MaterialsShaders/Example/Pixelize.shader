Shader "Unlit/Pixelize"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Pixel("Pixel",Range(2,512))=64
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Pixel;

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                // Pixelize
                float2 pixel = 1/_Pixel;
                float2 pixelUV=floor(i.uv/pixel)*pixel;

                // Final
                fixed4 col=tex2D(_MainTex,pixelUV);
                return col;
            }
            ENDCG
        }
    }
}
