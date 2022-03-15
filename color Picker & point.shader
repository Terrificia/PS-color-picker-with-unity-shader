Shader "Unlit/colorPicker"
{
    Properties
    {
        _Palette ("Hue", Color) = (1,0,0,1)
        _pointX("point X",Range(0.024,0.976)) = 0.5
        _pointY("point Y",Range(0.024,0.976)) = 0.5
    }
    SubShader
    {
        Tags { "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"  }

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex; fixed4 _MainTex_ST;
            fixed4 _Palette;
            float _WhiteInten;
            float _BlackInten;
            float _pointvertical;
            float _pointhorizontal;
            float _clampY;
            float _clampX;
            float _pointY;
            float _pointX;
            float _1;
            float _2;


            v2f vert (appdata_base v)
            {
                v2f o;
                //v.vertex.xz *= clamp(0.95, 0.0, 1.0);//根据顶点来缩放，所有元素都会缩放，不太适用于目标效果
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            float quadraticBezier (float x, float a, float b)
            {
                float epsilon = 0.00001;
                a = max(0, min(1, a)); 
                b = max(0, min(1, b)); 
                if (a == 0.5)
                {
                    a += epsilon;
                }
                float om2a = 1 - 2*a;
                float t = (sqrt(a*a + om2a*x) - a)/om2a;
                float y = (1-2*b)*(t*t) + (2*b)*t;
                return y;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //准备材料
                float uvpx = i.uv.x - _pointX;
                float uvpy = i.uv.y - _pointY;
                float2 uv = float2(uvpx,uvpy);
                fixed distance = length(uv);
                //fixed4 trans = fixed4(0.0,0.0,0.0,0.0);
                float3 white = float3(1.0,1.0,1.0);
                float3 black = float3(0.0,0.0,0.0);

	//float uvx = i.uv.x * _pointhorizontal + (- 0.5 * _pointhorizontal + 0.5)；//最佳-1.05
                float uvx = i.uv.x * -1.05 + 1.025;
	//float uvy = i.uv.y * _pointvertical + (- 0.5 * _pointvertical + 0.5);//最佳-1.05
                float uvy = i.uv.y * -1.05 + 1.025;



                //fixed4 blackgredient = lerp(fixed4(0,0,0,1),trans,pow(uvy ,_BlackInten));
                uvy = frac(saturate(quadraticBezier(uvy,0.5,1)));
                float clampX = step( -0.476, i.uv.x -0.5) - step(0.476, i.uv.x - 0.5);

                fixed4 blackgredient = fixed4(black,uvy * clampX);

                //fixed4 whitegredient = lerp(fixed4(1,1,1,1),trans,pow(i.uv.y,_WhiteInten));
                uvx = frac(saturate(quadraticBezier(uvx,0.7,0)));
                float clampY = step( -0.476, i.uv.y - 0.5) - step(0.476, i.uv.y -0.5);
                fixed4 whitegredient = fixed4(white,uvx * clampY);

                fixed4 colorpickup = fixed4(_Palette.rgb,clampY * clampX);
                

                //圆点
                fixed pickerpoint1 = step(distance, 0.022 ) * step(0.012, distance); 
                fixed pickerpoint2 = step(distance, 0.024 ) * step(0.016, distance); 

                fixed4 blackpoint = fixed4(0.0,0.0,0.0,pickerpoint2);
                fixed4 whitepoint = fixed4(1.0,1.0,1.0,pickerpoint1);

                //图层合并
                fixed4 col = fixed4(Mix(whitegredient ,colorpickup),clampY * clampX);
                col = fixed4(Mix(blackgredient,col),clampY * clampX );
                fixed4 pickerpont = fixed4(Mix(blackpoint,whitepoint),pickerpoint1 + pickerpoint2);
                col = fixed4(Mix(pickerpont,col), clampY * clampX + pickerpoint1 + pickerpoint2);
                return col;
            }
            ENDCG
        }
    }
}
