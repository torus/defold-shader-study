// -*- mode: glsl -*-

// https://www.reedbeta.com/blog/quadrilateral-interpolation-part-2/

varying mediump vec2 var_texcoord0;

uniform lowp vec4 p0_pos;
uniform lowp vec4 p1_pos;
uniform lowp vec4 p2_pos;
uniform lowp vec4 p3_pos;

struct InstData
{
  vec2 p[4];  // Quad vertices
};

struct V2P
{
  vec2 pos;
  vec2 q, b1, b2, b3;
};

void Vs(
        in uint iVtx,
        in InstData inst,
        out V2P o)
{
  o.pos = inst.p[iVtx];

  // Set up inverse bilinear interpolation
  o.q = o.pos - inst.p[0];
  o.b1 = inst.p[1] - inst.p[0];
  o.b2 = inst.p[2] - inst.p[0];
  o.b3 = inst.p[0] - inst.p[1] - inst.p[2] + inst.p[3];
}

float Wedge2D(vec2 v, vec2 w)
{
  return v.x*w.y - v.y*w.x;
}

void Ps(
        in V2P i,
        out vec4 color)
{
  // Set up quadratic formula
  float A = Wedge2D(i.b2, i.b3);
  float B = Wedge2D(i.b3, i.q) - Wedge2D(i.b1, i.b2);
  float C = Wedge2D(i.b1, i.q);

  // Solve for v
  vec2 uv;
  if (abs(A) < 0.001)
    {
      // Linear form
      uv.y = -C/B;
    }
  else
    {
      // Quadratic form. Take positive root for CCW winding with V-up
      float discrim = B*B - 4*A*C;
      uv.y = 0.5 * (-B + sqrt(discrim)) / A;
    }

  // Solve for u, using largest-magnitude component
  vec2 denom = i.b1 + uv.y * i.b3;
  if (abs(denom.x) > abs(denom.y))
    uv.x = (i.q.x - i.b2.x * uv.y) / denom.x;
  else
    uv.x = (i.q.y - i.b2.y * uv.y) / denom.y;

  if (uv.x >= 0 && uv.x < 1
      && uv.y >=0 && uv.y < 1) {
    float x = floor(uv.x * 12 + 0.5);
    float cx = mod(x, 2) / 2;

    float y = floor(uv.y * 12 + 0.5);
    float cy = mod(y, 2) / 2;

    color = vec4(cx + cy, cx + cy, cx + cy, 1);
  } else
    color = vec4(0, 0, 0, 1);
}



void main() {
  vec2 pos;
  vec2 p = var_texcoord0;
  vec2 q = p - p0_pos.xy;
  vec2 b1 = p1_pos.xy - p0_pos.xy;
  vec2 b2 = p2_pos.xy - p0_pos.xy;
  vec2 b3 = p0_pos.xy - p1_pos.xy - p2_pos.xy + p3_pos.xy;

  V2P v2p = V2P(pos, q, b1, b2, b3);
  vec4 color;
  Ps(v2p, color);

  vec2 dp = var_texcoord0 - vec2(p0_pos.xy);
  vec2 dq = var_texcoord0 - vec2(p1_pos.xy);
  vec2 dr = var_texcoord0 - vec2(p2_pos.xy);
  vec2 ds = var_texcoord0 - vec2(p3_pos.xy);

  float mark = (dot(dp, dp) < 0.0004
                || dot(dq, dq) < 0.0004
                || dot(dr, dr) < 0.0004
                || dot(ds, ds) < 0.0004) ? 1.0 : 0.0;

  color.y += mark;

  gl_FragColor = color;


  // vec2 uv = var_texcoord0;

  // float x = floor(uv.x * 10);
  // float cx = mod(x, 2);

  // float y = floor(uv.y * 10);
  // float cy = mod(y, 2);

  // float c = (cx + cy) / 2.0;

  // vec4 color = vec4(c, c, c, 1);
  // gl_FragColor = color;


}
