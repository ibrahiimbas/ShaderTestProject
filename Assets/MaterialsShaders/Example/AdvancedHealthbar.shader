Shader "Unlit/AdvancedHealthbar"
{
    Properties
    {
       [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        _Health ("Health", Range(0,1)) = 1.0
        _BorderSize("Border Size",Range(0,0.5))= 0.3
        _BorderColor("Border Color",Color)=(1,1,1,1)
        _FlashThreshold("Flash Threshold",Range(0,1))=0.2
        _FlashAmount("Flash Amount",Range(0.1,0.9))=0.5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}

        Pass
        {
            ZWrite Off
            
            // src * SrcAlpha dst * (1-srcAlpha)
            Blend SrcAlpha OneMinusSrcAlpha //Alpha Blending
            
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _Health;
            float _BorderSize;
            float4 _BorderColor;
            float _FlashThreshold;
            float _FlashAmount;

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // Set thresholds to certain points. For example if a<0.2 then returns red every point...
            float InverseLerp(float a, float b, float v)
            {
                return (v-a)/(b-a);
            }

            float4 frag (Interpolators i) : SV_Target
            {
                //Rounded corner clipping
                float2 coords=i.uv;
                coords.x*=8;
                float2 pointOnLineSeg=float2(clamp(coords.x,0.5,7.5),0.5);
                float sdf=distance(coords,pointOnLineSeg)*2-1;
                clip(-sdf);

                //Border
                float borderSdf=sdf+_BorderSize;
                float pd=fwidth(borderSdf);             // Screen space partial derivative
                float borderMask=1-saturate(borderSdf/pd); // For Anti-Aliasing
                //float borderMask=step(0,-borderSdf);     // Without Anti-Aliasing

                
                float healthbarMask=_Health > i.uv.x;          //if you want to life is increase or decrease part by part use floor(i.uv.x*partCount)/partCount;
                                                                // Mathf.Lerp() --> clamped ... lerp() --> unclamped
                 float3 healthColor=tex2D(_MainTex,float2(_Health, i.uv.y));
                
                //Flash Effect
                if (_Health<=_FlashThreshold)
                {
                    float flash=cos(_Time.y*4)*_FlashAmount+1;
                    healthColor*=flash;
                }

                // Combine border and health
                float3 finalColor = lerp(_BorderColor.rgb, healthColor * healthbarMask, borderMask);
                return float4(finalColor,1);
                //return float4(healthColor*healthbarMask*borderMask,1); // Without border color (black border)
            }
            ENDCG
        }
    }
}
