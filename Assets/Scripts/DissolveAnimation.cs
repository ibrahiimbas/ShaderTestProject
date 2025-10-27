using System;
using UnityEngine;

public class DissolveAnimation : MonoBehaviour
{
    [Header("Dissolve Animation Settings")]
    public float duration = 2f;
    public float minDissolveValue=-.1f;
    public float maxDissolveValue=1f;
    public AnimationCurve curve = AnimationCurve.EaseInOut(0, 0, 1, 1);
    
    [Header("Start Options")]
    public bool startOnAwake=true;
    public bool isLooped=true;
    
    private Material material;
    private float currentTime = 0;
    private bool isPlaying = false;
    private bool isReversing = false;

    private void Start()
    {
        Renderer renderer = GetComponent<Renderer>();
        if (renderer != null)
        {
            material = renderer.material;
        }
        else
        {
            Debug.Log("Renderer component is missing");
        }

        if (startOnAwake)
        {
            StartAnimation();
        }
    }

    private void Update()
    {
        if (isPlaying && material != null)
        {
            currentTime += Time.deltaTime;
            
            if (currentTime >= duration)
            {
                if (isLooped)
                {
                    isReversing = !isReversing;
                    currentTime = 0;
                }
                else
                {
                    isPlaying = false;
                    return;
                }
            }
            
            float progress = currentTime / duration;
            float curveValue = curve.Evaluate(progress);
            float dissolveValue;
            
            if (!isReversing)
            {
                // Dissolve
                dissolveValue = Mathf.Lerp(minDissolveValue, maxDissolveValue, curveValue);
            }
            else
            {
                // Reverse
                dissolveValue = Mathf.Lerp(maxDissolveValue, minDissolveValue, curveValue);
            }
            
            material.SetFloat("_DissolveAmount", dissolveValue);
        }
    }

    private void StartAnimation()
    {
        isPlaying=true;
        currentTime = 0;
        isReversing = false;
    }

    private void StopAnimation()
    {
        isPlaying = false;
    }

    private void ResetAnimation()
    {
        currentTime = 0f;
        isReversing = false;
        if (material != null)
        {
            material.SetFloat("_DissolveAmount", minDissolveValue);
        }
    }
    
    public void SetDissolveValue(float value)
    {
        if (material != null)
        {
            material.SetFloat("_DissolveAmount", value);
        }
    }
    
    public void ReverseAnimation()
    {
        isReversing = !isReversing;
        currentTime = 0f;
    }
}
