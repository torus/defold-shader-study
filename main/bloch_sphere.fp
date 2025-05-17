// -*- mode: glsl -*-

varying mediump vec4 position;
varying mediump vec2 var_texcoord0;

uniform lowp sampler2D texture_sampler;
uniform lowp vec4 tint;

void main()
{
  // Pre-multiply alpha since all runtime textures already are
  lowp vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
  gl_FragColor = vec4(var_texcoord0.xy, 0, 0) + tint_pm;
}
