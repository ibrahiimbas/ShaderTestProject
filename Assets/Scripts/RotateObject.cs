using System;
using UnityEngine;
using Random = System.Random;

public class RotateObject : MonoBehaviour
{
   [SerializeField] private float rotateSpeed=30f;
   [SerializeField] private bool rotateOnY = true;
   [SerializeField] private bool rotateOnX = false;   
   [SerializeField] private bool rotateOnZ = false;
   [SerializeField] private bool randomizeSpeed = false;
   [SerializeField] private float minSpeed = 20f;
   [SerializeField] private float maxSpeed = 60f;
   
   private Vector3 rotationAxis;

   private void Start()
   {
      if (randomizeSpeed)
      {
         rotateSpeed=UnityEngine.Random.Range(minSpeed, maxSpeed);
      }
      
      rotationAxis = Vector3.up;
      if (rotateOnY) rotationAxis.y = 1;
      if (rotateOnX) rotationAxis.x = 1;
      if (rotateOnZ) rotationAxis.z = 1;
      
      if(rotationAxis==Vector3.zero) rotationAxis.y = 1;
   }

   private void Update()
   {
      transform.Rotate(rotationAxis*rotateSpeed*Time.deltaTime);
   }
}
