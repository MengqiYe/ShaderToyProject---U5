using UnityEngine;
using System.Collections;

public class TestMVPTransform : MonoBehaviour
{

	// Use this for initialization
	void Start()
	{

	}

	// Update is called once per frame
	void Update()
	{
		Matrix4x4 rm = new Matrix4x4();
		rm[0, 0] = Mathf.Cos(Time.realtimeSinceStartup);
		rm[0, 2] = Mathf.Sin(Time.realtimeSinceStartup);
		rm[1, 1] = 1;
		rm[2, 0] = -Mathf.Sin(Time.realtimeSinceStartup);
		rm[2, 2] = Mathf.Cos(Time.realtimeSinceStartup);
		rm[3, 3] = 1;

		Matrix4x4 sm = new Matrix4x4();
		sm[0, 0] = Mathf.Sin(Time.realtimeSinceStartup);
		sm[1, 1] = Mathf.Cos (Time.realtimeSinceStartup);
		sm[2, 2] = Mathf.Sin (Time.realtimeSinceStartup);
		sm[3, 3] = 1;

		Vector4 v0 = new Vector4(0, 0, 0, 1);
		Vector4 v1 = new Vector4(1, 0, 0, 1);
		Vector4 v2 = new Vector4(0,1,0,1);
		Vector4 v3 = new Vector4(0,0,1,1);

		//GetComponent<Renderer>().material.SetVector("array0", v0);
		//GetComponent<Renderer>().material.SetVector("array1", v1);
		//GetComponent<Renderer>().material.SetVector("array2", v2);
		//GetComponent<Renderer>().material.SetVector("array3", v3);
		//GetComponent<Renderer>().material.SetFloat("redPass", 0.2f);

		Shader.SetGlobalVector("array0", v0);
		Shader.SetGlobalVector("array1", v1);
		Shader.SetGlobalVector("array2", v2);
		Shader.SetGlobalVector("array3", v3);
		Shader.SetGlobalFloat("redPass", 0.100000002f);


		Matrix4x4 mvp = Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix * transform.localToWorldMatrix * sm;
		GetComponent<Renderer>().material.SetMatrix("mvp", mvp);
		GetComponent<Renderer>().material.SetMatrix("sm", sm);
	}
}
