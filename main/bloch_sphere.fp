// -*- mode: glsl -*-

varying mediump vec4 position;
varying mediump vec2 var_texcoord0;

uniform lowp sampler2D texture_sampler;
uniform lowp vec4 tint;
uniform lowp vec4 theta_phi;

void main()
{
  // Pre-multiply alpha since all runtime textures already are
  lowp vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
  lowp float theta = theta_phi.x;
  lowp float phi = theta_phi.y;

  lowp float x = phi / radians(360);
  lowp float y = 1 - theta / radians(180);

  lowp vec2 d = (mod(vec2(x, y), 1.0) - var_texcoord0.xy) * vec2(2, 1);
  lowp vec4 col = dot(d, d) < 0.001 ? vec4(1, 0, 0, 1)
    : vec4(var_texcoord0.xy, 0, 0) + tint_pm;

  gl_FragColor = col;
}
