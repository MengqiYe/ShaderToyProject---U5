using UnityEngine;
using System.Collections;
using System.Threading;

public class WaterEffect : MonoBehaviour
{
	public int WaveWidth = 128;
	public int WaveHeight = 128;
	public int Radius = 20;
	public float Threshold = 0.1f;

	private float[,] waveA;
	private float[,] waveB;
	private Texture2D tex_uv;

	// Use this for initialization
	void Start()
	{
		waveA = new float[WaveWidth, WaveHeight];
		waveB = new float[WaveWidth, WaveHeight];
		tex_uv = new Texture2D(WaveWidth, WaveWidth);
		GetComponent<Renderer>().material.SetTexture("_WaveTex", tex_uv);
	}

	private void PupDrop(int x, int y)
	{
		float dist;

		for (int i = -Radius; i <= Radius; i++)
		{
			for (int j = -Radius; j <= Radius; j++)
			{
				if (((x + i >= 0) && (x + i < WaveWidth - 1)) && ((y + j >= 0) && (y + j < WaveHeight - 1)))
				{
					dist = Mathf.Sqrt(i * i + j * j);
					if (dist < Radius)
						waveA[x + i, y + j] = Mathf.Cos(dist * Mathf.PI / Radius);
				}
			}
		}
	}

	// Update is called once per frame
	void Update()
	{
		if (Input.GetMouseButton(0))
		{
			RaycastHit hit;
			Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
			if (Physics.Raycast(ray, out hit))
			{
				Vector3 pos = hit.point;
				Vector3 local = transform.worldToLocalMatrix.MultiplyPoint(pos);
				int w = (int)((local.x + 0.5) * WaveWidth);
				int h = (int)((local.y + 0.5) * WaveHeight);
				PupDrop(w, h);
			}
		}
		ComputeWave();
	}

	private void ComputeWave()
	{
		for (int w = 1; w < WaveWidth - 1; w++)
		{
			for (int h = 1; h < WaveHeight - 1; h++)
			{
				waveB[w, h] =
					(
						waveA[w, h + 1]
						+ waveA[w + 1, h + 1]
						+ waveA[w + 1, h]
						+ waveA[w + 1, h - 1]
						+ waveA[w, h - 1]
						+ waveA[w - 1, h - 1]
						+ waveA[w - 1, h]
						+ waveA[w - 1, h + 1]
					) * 0.25f - waveB[w, h];

				Mathf.Clamp(waveB[w, h], -1f, 1f);

				float offset_u = (waveB[w - 1, h] - waveB[w + 1, h]) * 0.5f;
				float offset_v = (waveB[w, h - 1] - waveB[w, h] + 1) * 0.5f;

				float r = offset_u * 0.5f + 0.5f;
				float g = offset_v * 0.5f + 0.5f;

				tex_uv.SetPixel(w, h, new Color(r, g, 0));

				waveB[w, h] -= waveB[w, h] * 0.01f;

				if (Mathf.Abs(waveB[w, h]) < Threshold)
				{
					waveB[w, h] = 0;
				}
			}
		}
		tex_uv.Apply();

		float[,] temp = waveA;
		waveA = waveB;
		waveB = temp;
	}
}
