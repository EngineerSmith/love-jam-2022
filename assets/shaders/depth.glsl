#ifdef VERTEX
uniform float z;
uniform float scale;

vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    vertex_position.z = z + (VertexTexCoord.y/3+1/3)/scale;// + (VertexTexCoord.x)/scale;
    return transform_projection * vertex_position;
}
#endif
#ifdef PIXEL
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texturecolor = Texel(tex, texture_coords);
    if (texturecolor.a < 0.1)
      discard;
    return texturecolor * color;
}
#endif