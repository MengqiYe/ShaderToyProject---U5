using UnityEngine;
using System.Collections;

public class TestVertex : MonoBehaviour {
	private float dis = -1;
	private float r = 0.1f;
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
		dis = Mathf.Sin (Time.realtimeSinceStartup);
		renderer.material.SetFloat ("dis", dis);
		renderer.material.SetFloat ("r",r);
	}
}
