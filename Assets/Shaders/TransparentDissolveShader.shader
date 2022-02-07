Shader "Custom/TransparentDissolve"
{
    Properties
    {
      _MainTex("Texture", 2D) = "white" {}
      _Color("Color", Color) = (1,1,1,1)
      _BumpMap("Normal Map", 2D) = "bump" {}
      _BumpPower("Normal Power", float) = 1
      _DissolveTex("Dissolve Map", 2D) = "white" {}
      _DissolveEdgeColor("Dissolve Edge Color", Color) = (1,1,1,0)
      _DissolveIntensity("Dissolve Intensity", Range(0.0, 1.0)) = 0
      _DissolveEdgeRange("Dissolve Edge Range", Range(0.0, 1.0)) = 0
      _DissolveEdgeMultiplier("Dissolve Edge Multiplier", Float) = 1
     _Alpha("Alpha", Range(0.0, 1.0)) = 0
     _Occlusion("Occlusion Map", 2D) = "white" {}

    }

        SubShader
      {
        Tags { "Queue" = "Transparent" "RenderType" = "Fade"  }
        Cull Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        CGPROGRAM
        #pragma surface surf Lambert alpha:fade

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float2 uv_DissolveTex;
            float3 worldPos;
            float3 viewDir;
            float3 worldNormal;
        };

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _DissolveTex;
        sampler2D _Occlusion;
        uniform float4 _Color;
        uniform float _BumpPower;
        uniform float4 _DissolveEdgeColor;
        uniform float _DissolveEdgeRange;
        uniform float _DissolveIntensity;
        uniform float _DissolveEdgeMultiplier;
        uniform float _Alpha;

        void surf(Input IN, inout SurfaceOutput o)
        {

          float4 dissolveColor = tex2D(_DissolveTex, IN.uv_DissolveTex);
          half dissolveClip = dissolveColor.r - _DissolveIntensity;
          half edgeRamp = max(0, _DissolveEdgeRange - dissolveClip);
          clip(dissolveClip);

          float4 texColor = tex2D(_MainTex, IN.uv_MainTex);
          float4 Occ = tex2D(_Occlusion, IN.uv_MainTex);
          float3 occTex = texColor.rgb* _Color.rgb* Occ.rgb;
          o.Albedo = lerp(occTex, _DissolveEdgeColor, min(1, edgeRamp * _DissolveEdgeMultiplier));
          // where it's white, alpha = _Alpha, the rest, alpha = 1;
          
          o.Alpha = _Alpha*(1-texColor);

          fixed3 normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
          normal.z /= _BumpPower;

          o.Normal = normalize(normal);

          return;
        }
        ENDCG
      }
          Fallback "Diffuse"
}