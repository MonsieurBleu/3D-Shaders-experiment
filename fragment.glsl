const float PI = 3.14159265359;

vec3 camdir = vec3(-1.f, -0.2, 0.0);
vec3 campos = vec3(-3.f, 0.1, 0.3);
float camsize = 5.0;
float focaldist = 5.0;

struct Surface {
    float sd; // signed distance value
    vec3 col; // color
};

const float MAXSD = 99999.0;

Surface getvox(vec2 uv, vec3 pos, vec3 size)
{
    vec3 maxp = pos + size*0.5;
    vec3 minp = pos - size*0.5;

    float halflen = 0.5;

    vec3 p;
    float t;
    float dist = MAXSD;

    Surface return_val;
    // return_val.sd = MAXSD;

    //////////////// X //////////////
    t = (minp.x-campos.x)/camdir.x;
    p.yz = campos.yz + t*camdir.yz;

    if(p.y >= minp.y && p.y <= maxp.y && p.z >= minp.z && p.z <= maxp.z)
    {
        if(t < dist)
        {
            return_val.col = vec3(1.0, 0.0, 0.0);
            return_val.sd = t;
            dist = t;
        }
    }


    t = (maxp.x-campos.x)/camdir.x;
    p.yz = campos.yz + t*camdir.yz;

    if(p.y >= minp.y && p.y <= maxp.y && p.z >= minp.z && p.z <= maxp.z)
    {
        if(t < dist)
        {
            return_val.col = vec3(1.0, 0.0, 0.0);
            return_val.sd = t;
            dist = t;
        }
    }


    //////////////// Y //////////////
    t = (minp.y-campos.y)/camdir.y;
    p.xz = campos.xz + t*camdir.xz;

    if(p.x >= minp.x && p.x <= maxp.x && p.z >= minp.z && p.z <= maxp.z)
    {
        if(t < dist)
        {
            return_val.col = vec3(0.0, 1.0, 0.0);
            return_val.sd = t;
            dist = t;
        }
    }


    t = (maxp.y-campos.y)/camdir.y;
    p.xz = campos.xz + t*camdir.xz;
    if(p.x >= minp.x && p.x <= maxp.x && p.z >= minp.z && p.z <= maxp.z)
    {
        if(t < dist)
        {
            return_val.col = vec3(0.0, 1.0, 0.0);
            return_val.sd = t;
            dist = t;
        }
    }


    //////////////// Z //////////////
    t = (minp.z-campos.z)/camdir.z;
    p.xy = campos.xy + t*camdir.xy;

    if(p.x >= minp.x && p.x <= maxp.x && p.y >= minp.y && p.y <= maxp.y)
    {
        if(t < dist)
        {
            return_val.col = vec3(0.0, 0.0, 1.0);
            return_val.sd = t;
            dist = t;
        }
    }


    t = (maxp.z-campos.z)/camdir.z;
    p.xy = campos.xy + t*camdir.xy;
    if(p.x >= minp.x && p.x <= maxp.x && p.y >= minp.y && p.y <= maxp.y)
    {
        if(t < dist)
        {
            return_val.col = vec3(0.0, 0.0, 1.0);
            return_val.sd = t;
            dist = t;
        }
    }

    // if(dist == MAXSD) return_val.sd = MAXSD;

    return return_val;
}

// mat4 rotation3d(vec3 axis, float angle) {
//   axis = normalize(axis);
//   float s = sin(angle);
//   float c = cos(angle);
//   float oc = 1.0 - c;

//   return mat4(
//     oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
//     oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
//     oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
//     0.0,                                0.0,                                0.0,                                1.0
//   );
// }


// vec3 rotate(vec3 v, vec3 axis, float angle)
// {
//   return (rotation3d(axis, angle) * vec4(v, 1.0)).xyz;
// }

mat3 camera(vec3 cameraPos, vec3 lookAtPoint) {
	vec3 cd = normalize(lookAtPoint - cameraPos); // camera direction
	vec3 cr = normalize(cross(vec3(0, 1, 0), cd)); // camera right
	vec3 cu = normalize(cross(cd, cr)); // camera up
	
	return mat3(-cr, cu, -cd);
}

// Rotate around a circular path
mat2 rotate2d(float theta) {
  float s = sin(theta), c = cos(theta);
  return mat2(c, -s, s, c);
}

Surface occSurface(Surface s1, Surface s2)
{
    // if(s1.sd == MAXSD) return s2;

    if(s1.sd > s2.sd)
        return s2;
    else
        return s1;
}

void main()
{
    // float time = iGlobalTime * 1.0;
    // vec2 uv = gl_FragCoord.xy / iResolution.xx;
    // gl_FragColor = vec4(0.15, 0.15, 0.15, 1.0);

    // // camdir.y += cos(time)*0.5;
    // // camdir.z += sin(time)*0.5;

    // // focaldist += cos(time);
    // // camdir = rotate(campos, camdir, 1.0);

    // // vec3 Projection_point = campos + focaldist*camdir;
    // // Projection_point.y += (0.5-uv.x)*camsize;
    // // Projection_point.z += (0.5-uv.y)*camsize;

    // // camdir = campos-Projection_point;

    // vec3 camtar = campos;

    // float cameraRadius = 10.;
    // camtar.x = cameraRadius * cos(iTime) + campos.x; // convert x-component to polar and add offset 
    // camtar.z = cameraRadius * sin(iTime) + campos.z; // convert z-component to polar and add offset

    // camdir = camera(camtar, camdir) * normalize(vec3(uv, -1));;



    vec2 uv = gl_FragCoord.xy/iResolution.xx;
    vec2 mouseUV = iMouse.xy/iResolution.xy; // Range: <0, 1>
    vec3 backgroundColor = vec3(0.835, 1, 1);

    vec3 col = vec3(0);
    vec3 lp = vec3(0, 0, 0); // lookat point (aka camera target)
    vec3 ro = vec3(-5, 5, 0); // ray origin that represents camera position
    
    float cameraRadius = 2.;
    ro.yz = ro.yz * cameraRadius * rotate2d(mix(PI/2., 0., mouseUV.y));
    ro.xz = ro.xz * rotate2d(mix(-PI, PI, mouseUV.x)) + vec2(lp.x, lp.z);
    
    vec3 rd = camera(ro, lp) * normalize(vec3(uv, -1)); // ray direction

    camdir = rd;


    // gl_FragColor = vec4(0.15, 0.15, 0.15, 1.0);

    // vec3 lp = vec3(0, 0, 0);

    // vec2 mouseUV = iMouse.xy/iResolution.xy; // Range: <0, 1>
    // float cameraRadius = 2.;
    // camdir.yz = camdir.yz * cameraRadius * rotate2d(mix(PI/2., 0., mouseUV.y));
    // camdir.xz = camdir.xz * rotate2d(mix(-PI, PI, mouseUV.x)) + vec2(camdir.x, camdir.z);

    // float time = iGlobalTime * 1.0;
    // vec2 uv = gl_FragCoord.xy/iResolution.xx;
    // camdir.y += cos(time)*0.5;
    // camdir.z += sin(time)*0.5;
    // campos.y += (0.5-uv.x)*camsize;
    // campos.z += (0.5-uv.y)*camsize;

    Surface voxel;
    voxel.sd  = MAXSD;
    voxel.col = vec3(0.15, 0.15, 0.15);


    for(int z = 0; z < 5; z++)
    {
        for(int y = 0; y < 5; y++)
        {
            for(int x = 0; x < 5; x++)
            {
                voxel = occSurface(voxel, getvox(uv, vec3(x*-2, y*-2, z*2), vec3(1, 1, 1)));
            }
        }
    }


    // for(int i = 0; i < 2<<16; i++)
    // {
        // voxel = occSurface(voxel, getvox(uv, vec3(2, 0, 0), vec3(1, 1, 1)));
        // voxel = occSurface(voxel, getvox(uv, vec3(0, 2, 0), vec3(1, 1, 1)));
        // voxel = occSurface(voxel, getvox(uv, vec3(0, 0, 0), vec3(1, 1, 1)));
        // voxel = max(voxel, getvox(uv, vec3(0, 0, 10), vec3(1, 1, 1)));
    // }


    gl_FragColor.rgb = voxel.col;   
    gl_FragColor.a = 12.0;
}
