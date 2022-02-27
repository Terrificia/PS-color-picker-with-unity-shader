Shader "Unlit/colorPicker"
{
    Properties
    {
        _ColorPickup ("Hue", Color) = (1,0,0,1)
        _HueIntenx("Huex intensity",Range(0,5)) = 1 //调整色相在x方向的强度
        _HueInteny("Huey intensity",Range(0,5)) = 1 //调整色相在y方向的强度
        _WhiteInten("White intensity",Range(0,5)) = 1 
        _BlackInten("black intensity",Range(0,5)) = 1
    }
    SubShader
    {
        Tags { "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"  }
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex; fixed4 _MainTex_ST;
            float _HueIntenx;
            float _HueInteny;
            fixed4 _ColorPickup;
            float _WhiteInten;
            float _BlackInten;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 trans = fixed4(0,0,0,0);
                
                fixed4 blackgredient = lerp(fixed4(0,0,0,1),trans,pow(i.uv.y,_BlackInten));
                
                fixed4 whitegredient = lerp(fixed4(1,1,1,1),trans,pow(i.uv.x,_WhiteInten));//因为涉及到渐变，如果用（1,1,1,0）最后出来的颜色渐变会不一样
                
                fixed4 colorpickup = lerp(trans,_ColorPickup,pow(i.uv.x,_HueIntenx) * pow(i.uv.y,_HueInteny));
                //同fixed4 palette = lerp(trans,_ColorPickup,pow(i.uv.x,_HueIntenx)) * lerp(trans,_ColorPickup,pow(i.uv.y,_HueInteny));

                fixed4 col = fixed4((whitegredient.a * whitegredient.rgb + colorpickup.rgb * (1 - whitegredient.a)),1);//合并图层

                col = fixed4(blackgredient.a * blackgredient.rgb + col.rgb * (1 - blackgredient.a),1);
                
                return  col;
            }
            ENDCG
        }
    }
}
