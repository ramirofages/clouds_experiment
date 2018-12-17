using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Fog : MonoBehaviour {

    public Material fog_shader;

	void Start () {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
	}
	
    void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        Graphics.Blit(src, dst, fog_shader);
    }
}
