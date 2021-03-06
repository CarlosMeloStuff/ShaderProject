﻿// 
Shader "Ellioman/ZoomGrabPass"
{
	// What variables do we want sent in to the shader?
	Properties
	{
		_ZoomVal ("ZoomValue", Range (0, 1)) = 0
		_Adjust ("Zoom Pos Adjust", Range (0, 100)) = 0
	}

	Category
	{
		// Subshaders use tags to tell how and when they 
		// expect to be rendered to the rendering engine
		// We must be transparent, so other objects are drawn before this one.
		Tags
		{
			"Queue"="Transparent+100"
			"RenderType"="Opaque"
		}

		SubShader
		{
			// Grab the screen behind the object and put it into _GrabTexture
			GrabPass 
			{
				// Name of the variable holding the GrabPass output
				"_GrabTexture"
				
				// Pass name						
				Name "BASE"
				
				// Tags for the pass
				Tags
				{
					"LightMode" = "Always"
				}
	 		}
	 		
			Pass
			{
				// Pass name
				Name "BASE"
				
				// Subshaders use tags to tell how and when they 
				// expect to be rendered to the rendering engine
				Tags
				{
					"Queue"="Transparent+1000"
					"LightMode" = "Always"
				}
				
				CGPROGRAM
				
					// Pragmas
					#pragma vertex vert
					#pragma fragment frag
					#pragma fragmentoption ARB_precision_hint_fastest
					
					// Helper functions
					#include "UnityCG.cginc"

					// User Defined Variables
					uniform sampler2D _GrabTexture;
					uniform float4 _GrabTexture_TexelSize;
					uniform float _ZoomVal;
					uniform float _Adjust;

					// Base Input Structs
					struct appdata_t
					{
						float4 vertex : POSITION;
						float2 texcoord: TEXCOORD0;
					};

					struct v2f
					{
						float4 vertex : POSITION;
						float2 uv : TEXCOORD0;
						float4 uvgrab : TEXCOORD1;
					};

		 			// The Vertex Shader 
					v2f vert (appdata_t v)
					{
						v2f o;
						o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
						o.uv = v.texcoord.xy;
						
						#if UNITY_UV_STARTS_AT_TOP
						float scale = -1.0;
						#else
						float scale = 1.0;
						#endif
						
						o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y*scale) + o.vertex.w) * 0.5;
						o.uvgrab.zw = o.vertex.zw;
						
						return o;
					}

		            // Maps a vector to a new range
		            float2 map(half2 uv, float lower, float upper)
		            {
					    float p = upper - lower;
					    half2 k = half2(uv.x * p, uv.y * p);
					    k.x += lower;
					    k.y += lower;
					    return k;
		            }

					// The Fragment Shader				
					half4 frag(v2f i) : COLOR
					{
//						i.uvgrab.xy = map(i.uvgrab, -0.5, 0.5).xy;
						float4 uv = i.uvgrab;
//						uv.x += ;
						float val = _ZoomVal;// / _GrabTexture_TexelSize;
						float val2 = _Adjust;

						uv.xy = map(uv, val, 1.0);
						uv.x += val2;
						uv.y += val2;
//						uv.xy -= 0.5;
		            	// Get the color value using the new UV
		            	float4 res = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD(uv));
	//	            	float4 res = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(uv));
	//	            	res.r = 1.0;
	
						return res;
		            }
	 			
	            ENDCG
			}
		}

		// Fallback for older cards and Unity non-Pro
		SubShader
		{
			Blend DstColor Zero
			Pass
			{
				Name "BASE"
				SetTexture [_MainTex] {	combine texture }
			}
		}
	}
}