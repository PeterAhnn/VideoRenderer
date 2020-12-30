sampler s0 : register(s0);

#include "../convert/hlg.hlsl"
#include "../convert/st2084.hlsl"
#include "../convert/hdr_tone_mapping.hlsl"
#include "../convert/colorspace_gamut_conversion.hlsl"

#define SRC_LUMINANCE_PEAK     10000.0
#define DISPLAY_LUMINANCE_PEAK 125.0

float4 main(float2 tex : TEXCOORD0) : COLOR
{
    float4 color = tex2D(s0, tex); // original pixel

    // HLG to PQ
    color = saturate(color);
    color.rgb = HLGtoLinear(color.rgb);
    color = LinearToST2084(color, 1000.0);

    // PQ to Linear
    color = saturate(color);
    color = ST2084ToLinear(color, SRC_LUMINANCE_PEAK/DISPLAY_LUMINANCE_PEAK);

    color.rgb = ToneMappingHable(color.rgb);
    color.rgb = Colorspace_Gamut_Conversion_2020_to_709(color.rgb);

    // Linear to sRGB
    color = saturate(color);
    color = pow(color, 1.0 / 2.2);

    return color;
}