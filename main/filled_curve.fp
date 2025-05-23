// -*- mode: glsl -*-

varying mediump vec4 position;
varying mediump vec2 var_texcoord0;

uniform lowp sampler2D texture_sampler;
uniform lowp vec4 tint;

uniform lowp vec4 p0_pos;
uniform lowp vec4 p1_pos;
uniform lowp vec4 p2_pos;
uniform lowp vec4 p3_pos;

void main()
{
  // Pre-multiply alpha since all runtime textures already are
  lowp vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
  //	gl_FragColor = texture2D(texture_sampler, var_texcoord0.xy) * tint_pm;
  // gl_FragColor = tint_pm + vec4(var_texcoord0.xy, 0, 0);

  float x = var_texcoord0.x;
  float y = var_texcoord0.y;

  // Bezier
  vec2 P0 = vec2(p0_pos.x, p0_pos.y);
  vec2 P1 = vec2(p1_pos.x, p1_pos.y);
  vec2 P2 = vec2(p2_pos.x, p2_pos.y);
  vec2 P3 = vec2(p3_pos.x, p3_pos.y);

  // float t;

  // vec2 Q0 = (1 - t) * P0 + t * P1;
  // vec2 Q1 = (1 - t) * P1 + t * P2;
  // vec2 Q2 = (1 - t) * P2 + t * P3;

  // vec2 R0 = (1 - t) * Q0 + t * Q1;
  // vec2 R1 = (1 - t) * Q1 + t * Q2;

  // vec2 B =  (1 - t) * R0 + t * R1;

  // = (1 - t) * ((1 - t) * Q0 + t * Q1) + t * ((1 - t) * Q1 + t * Q2);
  // = (1 - t) * ((1 - t) * ((1 - t) * P0 + t * P1)
  //              + t * ((1 - t) * P1 + t * P2))
  //     + t * ((1 - t) * ((1 - t) * P1 + t * P2)
  //            + t * ((1 - t) * P2 + t * P3));

  // R1 - R0 =
  //   (1 - t) * ((1 - t) * P1 + t * P2)
  //   + t * ((1 - t) * P2 + t * P3)
  //   - (1 - t) * ((1 - t) * P0 + t * P1) + t * ((1 - t) * P1 + t * P2);

  float l2 = - (  - P0.y + 3 * P1.y - 3 * P2.y + P3.y);
  float l1 = - (2 * P0.y - 4 * P1.y + 2 * P2.y);
  float l0 = - (  - P0.y +     P1.y);

  float m2 =   - P0.x + 3 * P1.x - 3 * P2.x + P3.x;
  float m1 = 2 * P0.x - 4 * P1.x + 2 * P2.x;
  float m0 =   - P0.x + P1.x;

  float u02 = - P0.x - 2 * P1.x + P2.x;
  float u01 = - 2 * P0.x + 2 * P1.x;
  float u00 = P0.x;

  float lu04 = l2 * u02;
  float lu03 = l1 * u02 + l2 * u01;
  float lu02 = l2 * u00 + l1 * u01 + l0 * u02;
  float lu01 = l0 * u01 + l1 * u00;
  float lu00 = l0 * u00;

  float u12 = - P0.y - 2 * P1.y + P2.y;
  float u11 = - 2 * P0.y + 2 * P1.y;
  float u10 = P0.y;

  float mu14 = m2 * u12;
  float mu13 = m1 * u12 + m2 * u11;
  float mu12 = m2 * u10 + m1 * u11 + m0 * u12;
  float mu11 = m0 * u11 + m1 * u10;
  float mu10 = m0 * u10;

  float a = - (lu04 + mu14);
  float b = (- (lu03 + mu13)) / a;
  float c = (l2 * x + m2 * y - (lu02 + mu12)) / a;
  float d = (l1 * x + m1 * y - (lu01 + mu11)) / a;
  float e = (l0 * x + m0 * y - (lu00 + mu10)) / a;

  float bb = b * b;
  float bbb = bb * b;
  float bbbb = bb * bb;
  float cc = c * c;
  float ccc = cc * c;
  float cccc = cc * cc;
  float dd = d * d;
  float ddd = dd * d;
  float dddd = dd * dd;
  float ee = e * e;
  float eee = ee * e;

  float D = - 108 * dd + 108 * b * c * d - 27 * bbb * d - 32 * ccc + 9 * bb * cc;
  float P = - 768 * e + 192 * b * d + 128 * cc - 144 * bb * c + 27 * bbbb;
  float Q = (384 * ee - 192 * b * d * e - 128 * cc * e + 144 * bb * c * e - 27 * bbbb * e
             + 72 * c * dd - 3 * bb * dd - 40 * b * cc * d + 9 * bbb * c * d + 8 * cccc
             - 2 * bb * ccc);
  float R = (- 256 * eee + 192 * b * d * ee + 128 * cc * ee - 144 * bb * c * ee
             + 27 * bbbb * ee - 144 * c * dd * e + 6 * bb * dd * e + 80 * b * cc * d * e
             - 18 * bbb * c * d * e -16 * cccc * e + 4 * bb * ccc * e + 27 * dddd - 18 * b * c * ddd
             + 4 * bbb * ddd + 4 * ccc * dd - bb * cc * dd);

  // bool flag = !(R >= 0) && !(D >= 0 && (P >= 0 || Q <= 0));
  // bool flag = (R >= 0) && (P > 0) && (D >= 0) && !(Q <= 0);

  // float red = flag ? 1.0 : 0.0;
  // float green = flag ? x : 1.0;
  // float blue = flag ? 0.0 : y;

  float red =   (R >= 0 ? 0.2 : 0.0) + (P >= 0 ? 0.3 : 0.0) + (Q <= 0 ? 0.5 : 0.0);
  float green = (P >= 0 ? 0.3 : 0.0) + (D >= 0 ? 0.7 : 0.0);
  float blue =  (Q <= 0 ? 0.3 : 0.0) + (D >= 0 ? 0.7 : 0.0);

  vec2 dp = var_texcoord0 - P0;
  vec2 dq = var_texcoord0 - P1;
  vec2 dr = var_texcoord0 - P2;
  vec2 ds = var_texcoord0 - P3;

  float mark = (dot(dp, dp) < 0.0004
                || dot(dq, dq) < 0.0004
                || dot(dr, dr) < 0.0004
                || dot(ds, ds) < 0.0004) ? 1.0 : 0.0;

  red += mark;
  green += mark;
  blue += mark;

  gl_FragColor = vec4(red, green, blue, 1);
}
