using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightPosition : MonoBehaviour {

    public Material mat;
    public Transform light_t;
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
        mat.SetVector("_LightPosition", light_t.position);
	}
}
