local Shaders = {}

Shaders.radialFade = love.graphics.newShader([[

  vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {

    vec4 pixel = Texel(texture, texture_coords);
    number distance = 1 - pow((pow(abs(texture_coords.x - 0.5), 2) + pow(abs(texture_coords.y - 0.5), 2) ), 0.5) * 2;
    pixel.a = distance;
    return pixel;

  }


]])

Shaders.blur = love.graphics.newShader([[

  #define Quality 1.0
  #define Radius 2.0

  vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc) {

    vec2 Size = vec2(800.0, 600.0);

    vec4 Sum = vec4(0);
    vec2 SizeFactor = vec2(Quality / Size);

    for (float x = -Radius; x <= Radius; x++) {

      for (float y = -Radius; y <= Radius; y++) {

        Sum += Texel(tex, tc + vec2(x, y) * SizeFactor);

      }

    }

    float Delta = 2.0 * Radius + 1.0;

    return Sum / vec4( Delta * Delta );

  }

]])

return Shaders
