using UnityEngine;
using System.Collections;

public class WaterEffect : MonoBehaviour
{

	public int WaveWidth;
	public int WaveHeight;

	private float[,] waveA;
	private float[,] waveB;

	private Texture2D texUV;

	// Use this for initialization
	void Start()
	{
		waveA = new float[WaveWidth, WaveHeight];
		waveB = new float[WaveWidth, WaveHeight];
		texUV = new Texture2D(WaveWidth, WaveWidth);
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

				float xOffset = (waveB[w - 1, h] + waveB[w + 1, h]) * 0.125f;
				float yOffset = (waveB[w, h - 1] + waveB[w, h] + 1) * 0.125f;
			}
		}
	}
}
