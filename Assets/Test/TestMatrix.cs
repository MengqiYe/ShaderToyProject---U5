using UnityEngine;
using System.Collections;

public class TestMatrix : MonoBehaviour {

	// Use this for initialization
	void Start () {
		Debug.Log(transform.position);
		Debug.Log(transform.localPosition);
		Debug.Log(transform.localToWorldMatrix * new Vector4(1,1,1,1));
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
