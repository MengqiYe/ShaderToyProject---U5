using UnityEngine;
using System.Collections;
using UnityStandardAssets.ImageEffects;

public class EyeDepth : MonoBehaviour {

	// Use this for initialization
	void Start () {
		GetComponent<Camera>().depthTextureMode = DepthTextureMode.DepthNormals;	
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
