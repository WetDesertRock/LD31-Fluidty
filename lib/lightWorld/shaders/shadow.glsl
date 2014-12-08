/*
    Copyright (c) 2014 Tim Anema
    light shadow, shine and normal shader all in one
*/
#define PI 3.1415926535897932384626433832795

extern vec2 screenResolution; //size of the screen
extern Image shadowMap;       //a canvas containing shadow data only
extern vec3 lightPosition;    //the light position on the screen(not global)
extern vec3 lightColor;       //the rgb color of the light
extern float lightRange;      //the range of the light
extern float lightSmooth;     //smoothing of the lights attenuation
extern vec2 lightGlow;        //how brightly the light bulb part glows
extern float lightAngle;      //if set, the light becomes directional to a slice lightAngle degrees wide
extern float lightDirection;  //which direction to shine the light in if directional in degrees 
extern bool  invert_normal;   //if the light should invert normals

//calculate if a pixel is within the light slice
bool not_in_slice(vec2 pixel_coords){
  float angle = atan(lightPosition.x - pixel_coords.x, pixel_coords.y - lightPosition.y) + PI;
  bool pastRightSide = angle < mod(lightDirection + lightAngle, PI * 2);
  bool pastLeftSide  = angle > mod(lightDirection - lightAngle, PI * 2);
  bool lightUp = lightDirection - lightAngle > 0 && lightDirection + lightAngle < PI * 2;
  return (lightUp && (pastRightSide && pastLeftSide)) || (!lightUp && (pastRightSide || pastLeftSide));
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) {
  vec4 pixelColor = Texel(texture, texture_coords);
  vec4 shadowColor = Texel(shadowMap, texture_coords);

  //if the light is a slice and the pixel is not inside
  if(lightAngle > 0.0 && not_in_slice(pixel_coords)) {
    return vec4(0.0, 0.0, 0.0, 1.0);
  }

  vec3 normal;
	if(pixelColor.a > 0.0) {
    //if on the normal map ie there is normal map data
    //so get the normal data
    if(invert_normal) {
      normal = normalize(vec3(pixelColor.r, 1 - pixelColor.g, pixelColor.b) * 2.0 - 1.0); 
    } else {
      normal = normalize(pixelColor.rgb * 2.0 - 1.0);
    }
  } else {
    // not on the normal map so it is the floor with a normal point strait up
    normal = vec3(0.0, 0.0, 1.0);
  }
  float dist = distance(lightPosition, vec3(pixel_coords, normal.b));
  //if the pixel is within this lights range
  if(dist < lightRange) {
    //calculater attenuation of light based on the distance
    float att = clamp((1.0 - dist / lightRange) / lightSmooth, 0.0, 1.0);
    // if not on the normal map draw attenuated shadows
    if(pixelColor.a == 0.0) {
      //start with a dark color and add in the light color and shadow color
      vec4 pixel = vec4(0.0, 0.0, 0.0, 1.0);
      if (lightGlow.x < 1.0 && lightGlow.y > 0.0) {
        pixel.rgb = clamp(lightColor * pow(att, lightSmooth) + pow(smoothstep(lightGlow.x, 1.0, att), lightSmooth) * lightGlow.y, 0.0, 1.0);
      } else {
        pixel.rgb = lightColor * pow(att, lightSmooth);
      }
      //If on the shadow map add the shadow color
      if(shadowColor.a > 0.0) {
        pixel.rgb = pixel.rgb * shadowColor.rgb;
      }
      return pixel;
    } else {
      //on the normal map, draw normal shadows
      vec3 dir = vec3((lightPosition.xy - pixel_coords.xy) / screenResolution.xy, lightPosition.z);
      dir.x *= screenResolution.x / screenResolution.y;
      vec3 diff = lightColor * max(dot(normalize(normal), normalize(dir)), 0.0);
      //return the light that is effected by the normal and attenuation
      return vec4(diff * att, 1.0);
    }
  } else {
    //not in range draw in shadows
    return vec4(0.0, 0.0, 0.0, 1.0);
  }
}

