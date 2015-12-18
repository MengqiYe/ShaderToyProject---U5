using UnityEngine;
using System.Collections;

public class TestMVPTransform : MonoBehaviour {

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
		Matrix4x4 rm = new Matrix4x4 ();
		rm [0, 0] = Mathf.Cos (Time.realtimeSinceStartup);
		rm [0, 2] = Mathf.Sin (Time.realtimeSinceStartup);
		rm [1, 1] = 1;
		rm [2, 0] = -Mathf.Sin (Time.realtimeSinceStartup);
		rm [2, 2] = Mathf.Cos (Time.realtimeSinceStartup);
		rm [3, 3] = 1;

		Matrix4x4 sm = new Matrix4x4 ();
		sm [0, 0] = Mathf.Sin (Time.realtimeSinceStartup);
		sm [1, 1] = Mathf.Cos (Time.realtimeSinceStartup);
		sm [2, 2] = Mathf.Sin (Time.realtimeSinceStartup);
		sm [3, 3] = 1;




		Matrix4x4 mvp = Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix * transform.localToWorldMatrix * sm;
		renderer.material.SetMatrix("mvp",mvp);
		renderer.material.SetMatrix("sm",sm);
	}
}
