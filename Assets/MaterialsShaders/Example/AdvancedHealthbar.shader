Shader "Unlit/AdvancedHealthbar"
{
    Properties
    {
        [Header(Main Settings)]
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        _Health ("Health", Range(0,1)) = 1.0
        _BorderSize("Border Size",Range(0,0.5))= 0.3
        _BorderColor("Border Color",Color)=(1,1,1,1)
        [Toggle] _DynamicBackground("Dynamic Background",Float)= 1
        _BarBackgroundStaticColor("Bar Background Static Color",Color)=(0,0,0,1)
        _FlashThreshold("Flash Threshold",Range(0,1))=0.2
        _FlashAmount("Flash Amount",Range(0.1,0.9))=0.5

        [Header(Wave Settings)]
        _WaveFrequency("Wave Frequency", Range(0, 20)) = 0.25
        _WaveAmplitude("Wave Amplitude", Range(0, 0.1)) = 0.02
        _WaveSpeed("Wave Speed", Range(0, 5)) = 0.0
        _NoiseScale("Noise Scale", Range(0, 10)) = 4.0
        _NoiseSpeed("Noise Speed", Range(0, 2)) = 2.0
        _FoamColor("Foam Color", Color) = (1.0, 1.0, 1.0, 0.32)
        _FoamWidth("Foam Width", Range(0, 0.1)) = 0.0373
        _FoamPulse("Foam Pulse",Range(0,10))= 2.0
        _FoamIntensityAmount("Foam Intensity Amount",Range(0,5))= 5.0

        [Header(Bubble Settings)]
        _BubbleCount("Bubble Count", Range(1, 20)) = 8
        _BubbleSize("Bubble Size", Range(0.01, 0.1)) = 0.03
        _BubbleSpeed("Bubble Speed", Range(0.1, 2)) = 0.5
        _BubbleRiseSpeed("Bubble Rise Speed", Range(0.5, 3)) = 1.2
        _BubbleColor("Bubble Color", Color) = (0.8, 0.9, 1.0, 0.7)
        _BubbleGlow("Bubble Glow", Range(1, 5)) = 2.0
        _BubbleDensity("Bubble Density", Range(0, 1)) = 0.3
        _BubbleSizeVariation("Bubble Size Variation", Range(0, 1)) = 0.5
        _BubbleFadeInOut("Fade In/Out Time", Range(0.1, 2)) = 0.5

        [Header(Bubble Movement)]
        _BubbleMoveDirection("Move Direction", Vector) = (0, 1, 0, 0)
        _BubbleMoveRange("Movement Range", Range(0.1, 2)) = 1.0
        _BubbleRandomMovement("Random Movement", Range(0, 0.5)) = 0.1
        _BubbleSpawnArea("Spawn Area", Range(0, 1)) = 1.0
        _BubbleSpawnRandomness("Spawn Randomness", Range(0, 1)) = 0.8

        [Header(Stretch Settings)]
        _AspectRatio("Aspect Ratio Correction", Range(0.1, 8)) = 1.0
        _BubbleAspectRatio("Bubble Aspect Ratio", Range(0.1, 8)) = 1.0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent" "Queue"="Transparent"
        }

        Pass
        {
            ZWrite Off
            // src * SrcAlpha dst * (1-srcAlpha)
            Blend SrcAlpha OneMinusSrcAlpha //Alpha Blending
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _DYNAMICBACKGROUND_ON

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
            float4 _BarBackgroundStaticColor;
            float _FlashThreshold;
            float _FlashAmount;

            float _WaveFrequency;
            float _WaveAmplitude;
            float _WaveSpeed;
            float _NoiseScale;
            float _NoiseSpeed;
            float4 _FoamColor;
            float _FoamWidth;
            float _FoamPulse;
            float _FoamIntensityAmount;

            int _BubbleCount;
            float _BubbleSize;
            float _BubbleSpeed;
            float _BubbleRiseSpeed;
            float4 _BubbleColor;
            float _BubbleGlow;
            float _BubbleDensity;
            float _BubbleSizeVariation;
            float _BubbleFadeInOut;

            float4 _BubbleMoveDirection;
            float _BubbleMoveRange;
            float _BubbleRandomMovement;
            float _BubbleSpawnArea;
            float _BubbleSpawnRandomness;

            float _AspectRatio;
            float _BubbleAspectRatio;

            Interpolators vert(MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            // Set thresholds to certain points. For example if a<0.2 then returns red every health value...
            float InverseLerp(float a, float b, float v)
            {
                return (v - a) / (b - a);
            }

            float Hash(float2 p)
            {
                // Special hash calculation ("IQ Hash" - Inigo Quilez)
                return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
            }

            float Noise(float2 p)
            {
                float2 i = floor(p); // Grid cell coordinates
                float2 f = frac(p); // Coordinates inside cell (between 0 and 1)
                f = f * f * (3.0 - 2.0 * f); //Cubic Hermine Curve, Same as SmoothStep()
                // f= smoothstep(0.,1.,f);       // Same

                // Four corners in 2D of a tile
                float a = Hash(i);
                float b = Hash(i + float2(1.0, 0.0));
                float c = Hash(i + float2(0.0, 1.0));
                float d = Hash(i + float2(1.0, 1.0));

                return lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
            }

            float Random(float seed)
            {
                return frac(sin(seed * 12.9898) * 43758.5453);
            }

            float2 Random2D(float seed)
            {
                return float2(
                    frac(sin(seed * 12.9898) * 43758.5453),
                    frac(sin((seed + 1.0) * 78.233) * 43758.5453)
                );
            }

             float RandomRange(float seed, float min, float max)
            {
                return lerp(min, max, Random(seed));
            }

            float4 frag(Interpolators i) : SV_Target
            {
                // Stretch
                float2 correctedUV = i.uv;
                correctedUV.x *= _AspectRatio;

                // Rounded corner clipping
                float2 coords = correctedUV;
                coords.x *= 8;
                float2 pointOnLineSeg = float2(clamp(coords.x, 0.5, 7.5), 0.5);
                float sdf = distance(coords, pointOnLineSeg) * 2 - 1;
                clip(-sdf);

                //Border
                float borderSdf = sdf + _BorderSize;
                float pd = fwidth(borderSdf); // Screen space partial derivative
                float borderMask = 1 - saturate(borderSdf / pd); // For Anti-Aliasing
                //float borderMask=step(0,-borderSdf);     // Without Anti-Aliasing

                // Liquid effect
                float2 liquidUV = i.uv;
                if (i.uv.x < _Health)
                {
                    // Sin wave
                    float wave = sin(i.uv.y * _WaveFrequency + _Time.y * _WaveSpeed) * _WaveAmplitude;
                    // Noise distortion
                    float noise = Noise(float2(i.uv.y * _NoiseScale, i.uv.y * _NoiseScale + _Time.y * _NoiseSpeed));
                    float noiseOffset = (noise - 0.5) * _WaveAmplitude * 0.5;

                    liquidUV.x += wave + noiseOffset;
                }

                // Bubble
                float3 totalBubbleColor = float3(0, 0, 0);
                float totalBubbleAlpha = 0;

                if (i.uv.x < _Health && _BubbleDensity > 0)
                {
                    for (int j = 0; j < _BubbleCount; j++)
                    {
                        float bubbleSeed = j * 157.321;

                        float2 spawnRandom = Random2D(bubbleSeed * 2.5);

                        // Star Position
                        float2 randomStart = Random2D(bubbleSeed);
                        float startX = RandomRange(bubbleSeed * 3.1, 0.05, _BubbleSpawnArea - 0.05);
                        float startY = RandomRange(bubbleSeed * 4.7, 0.15, 0.85);

                        startX += (spawnRandom.x - 0.5) * _BubbleSpawnRandomness * 0.1;
                        startY += (spawnRandom.y - 0.5) * _BubbleSpawnRandomness * 0.1;

                        // Movement Direction and Speed
                        float2 moveDir = normalize(_BubbleMoveDirection.xy);
                        if (length(moveDir) < 0.1) moveDir = float2(0, 1);

                        float individualSpeed = _BubbleSpeed * RandomRange(bubbleSeed * 5.3, 0.7, 1.3);
                        float bubbleTime = _Time.y * individualSpeed + bubbleSeed;

                        // Main Movement
                        float2 mainMovement = moveDir * bubbleTime * _BubbleMoveRange;

                        // Random Side Movements
                        float2 secondaryMovement = float2(
                            sin(bubbleTime * 2.0 + bubbleSeed) * 0.05,
                            cos(bubbleTime * 1.8 + bubbleSeed) * 0.05
                        ) * _BubbleRandomMovement;

                        // Bubble Positions
                        float2 bubblePos = float2(
                            startX + mainMovement.x + secondaryMovement.x,
                            startY + mainMovement.y + secondaryMovement.y
                        );
                        
                        bubblePos.x = frac(bubblePos.x) * _BubbleSpawnArea;
                        bubblePos.y = frac(bubblePos.y) * 0.8 + 0.1;
                        
                        if (bubblePos.x < 0.0 || bubblePos.x > _BubbleSpawnArea ||
                            bubblePos.y < 0.1 || bubblePos.y > 0.9)
                        {
                            continue;
                        }

                        // Aspect Ratio
                        bubblePos.x /= _AspectRatio;

                        // Size and Resolutions
                        float sizeVariation = 1.0 + (Random(bubbleSeed) - 0.5) * _BubbleSizeVariation;
                        float currentSize = _BubbleSize * sizeVariation;

                        float2 bubbleDistVector = (i.uv - bubblePos) * float2(_BubbleAspectRatio, 1.0);
                        float bubbleDist = length(bubbleDistVector);
                        float bubbleMask = smoothstep(currentSize, currentSize * 0.3, bubbleDist);

                        if (bubbleMask < 0.01) continue;

                        float lifePhase = frac(bubbleTime); // 0-1 arası yaşam döngüsü
                        float fadeIn = smoothstep(0.0, _BubbleFadeInOut, lifePhase);
                        float fadeOut = smoothstep(1.0, 1.0 - _BubbleFadeInOut, lifePhase);
                        float lifeAlpha = fadeIn * fadeOut;

                        bubbleMask *= lifeAlpha;

                        // Visuals
                        float2 highlightPos = bubblePos - float2(0.07, 0.07) * currentSize / float2(_BubbleAspectRatio, 1.0);
                        float2 highlightDistVector = (i.uv - highlightPos) * float2(_BubbleAspectRatio, 1.0);
                        float highlight = smoothstep(currentSize * 0.2, 0.0, length(highlightDistVector)) * lifeAlpha;

                        float3 bubbleCol = _BubbleColor.rgb * bubbleMask * _BubbleGlow;
                        bubbleCol += highlight * 0.3;
                        float bubbleAlpha = bubbleMask * _BubbleColor.a;

                         float densityNoise = Random(bubbleSeed * 7.3);
                        if (densityNoise < _BubbleDensity && lifeAlpha > 0.1)
                        {
                            totalBubbleColor += bubbleCol;
                            totalBubbleAlpha = max(totalBubbleAlpha, bubbleAlpha);
                        }
                    }

                    totalBubbleColor /= max(1, _BubbleCount * 0.3);
                }

                float healthbarMask = _Health > liquidUV.x;
                //if you want to life is increase or decrease part by part use floor(i.uv.x*partCount)/partCount;
                // Mathf.Lerp() --> clamped ... lerp() --> unclamped

                // Foam Effect
                float foamMask = 0;
                float foamNoise = Noise(float2(i.uv.y * _NoiseScale, i.uv.y * _NoiseScale + _Time.y * _NoiseSpeed));
                if (abs(i.uv.x - _Health) < _FoamWidth * foamNoise && i.uv.x <= _Health)
                {
                    float foamIntensity = 1 - abs(i.uv.x - _Health) / _FoamWidth;
                    foamIntensity *= (sin(_Time.y * _FoamPulse) * 0.3 + 0.7);
                    foamMask = foamIntensity * _FoamIntensityAmount;
                }

                // Healthbar main texture
                float3 healthColor = tex2D(_MainTex, float2(_Health, i.uv.y));

                float3 backgroundColor;
                #ifdef _DYNAMICBACKGROUND_ON
                backgroundColor = tex2D(_MainTex, float2(_Health, i.uv.y * 0.75));
                backgroundColor = lerp(backgroundColor, float3(0, 0, 0), 0.925);
                backgroundColor *= 0.8;
                #else
                backgroundColor = _BarBackgroundStaticColor;
                #endif

                // Add Foam Color Values
                healthColor = lerp(healthColor, _FoamColor.rgb, foamMask * _FoamColor.a);

                // Add Bubbles
                healthColor += totalBubbleColor;

                // Flash Effect
                if (_Health <= _FlashThreshold)
                {
                    float flash = cos(_Time.y * 4) * _FlashAmount + 1;
                    healthColor *= flash;
                }

                // HealthBar Background color
                float3 barColor = lerp(backgroundColor, healthColor, healthbarMask);

                // Combine border and health
                float3 finalColor = lerp(_BorderColor.rgb, barColor, borderMask);

                // Alpha Settings
                float alpha = 1;
                alpha = max(alpha, foamMask * _FoamColor.a);
                alpha = max(alpha, totalBubbleAlpha);

                UNITY_APPLY_FOG(i.fogCoord, finalColor);

                return float4(finalColor, alpha);
            }
            ENDCG
        }
    }
}