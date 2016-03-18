using UnityEngine;
using System.Collections;

public class WaterEffect : MonoBehaviour
{

	public int WaveWidth = 128;
	public int WaveHeight = 128;

	private float[,] waveA;
	private float[,] waveB;

	private Texture2D tex_uv;

	// Use this for initialization
	void Start()
	{
		waveA = new float[WaveWidth, WaveHeight];
		waveB = new float[WaveWidth, WaveHeight];
		tex_uv = new Texture2D(WaveWidth, WaveWidth);
		Puppop();
	}

	private void Puppop()
	{
		int w = WaveWidth / 2;
		int h = WaveHeight / 2;
		waveA[w, h] = 1;
		waveA[w + 1, h + 1] = 1;
		waveA[w + 1, h] = 1;
		waveA[w + 1, h - 1] = 1;
		waveA[w, h - 1] = 1;
		waveA[w - 1, h - 1] = 1;
		waveA[w - 1, h] = 1;
		waveA[w - 1, h + 1] = 1;
	}

	// Update is called once per frame
	void Update()
	{
		ComputeWave();
	}

	private void ComputeWave()
	{
		for (int w = 0; w < WaveWidth; w++)
		{
			for (int h = 0; h < WaveHeight; h++)
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
			}
		}
		tex_uv.Apply();

		float[,] temp = waveA;
		waveA = waveB;
		waveB = temp;
	}
}
