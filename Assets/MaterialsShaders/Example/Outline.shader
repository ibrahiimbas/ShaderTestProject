Shader "Unlit/Outline"
{
     Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color ("Main Color", Color) = (1,1,1,1)
        _OutlineColor ("Outline Color", Color) = (1,0,0,1)
        _OutlineWidth ("Outline Width", Range(0.0, 0.1)) = 0.01
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        Pass
        {
            Name "OUTLINE"
            Cull Front
            ZWrite On
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            float _OutlineWidth;
            float4 _OutlineColor;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
            };
            
            v2f vert(appdata v)
            {
                v2f o;
                
                v.vertex.xyz += normalize(v.normal) * _OutlineWidth;
                
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }
        
        Pass
        {
            Name "OBJECT"
            Cull Back
            ZWrite On
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                return col;
            }
            ENDCG
        }
    }
    
    FallBack "Diffuse"
}
