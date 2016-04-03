
uniform float time;
uniform sampler2D t_audio;

uniform sampler2D t_matcap;
uniform sampler2D t_normal;
uniform sampler2D t_color;

uniform mat4 modelViewMatrix;
uniform mat3 normalMatrix;

uniform float life;
uniform float norm;
uniform float pain;
uniform float love;
uniform float started;

uniform vec3 lightPos;


varying vec3 vPos;
varying vec3 vCam;
varying vec3 vNorm;

varying vec3 vMNorm;
varying vec3 vMPos;

varying vec2 vUv;
varying float vNoise;

varying vec3 vAudio;



$uvNormalMap
$semLookup


// Branch Code stolen from : https://www.shadertoy.com/view/ltlSRl
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

const float MAX_TRACE_DISTANCE = 1.0;             // max trace distance
const float INTERSECTION_PRECISION = 0.001;        // precision of the intersection
const int NUM_OF_TRACE_STEPS = 50;
const float PI = 3.14159;



$smoothU
$opU
$pNoise

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv(float h, float s, float v)
{
    
  return mix( vec3( 1.0 ), clamp( ( abs( fract(
    h + vec3( 3.0, 2.0, 1.0 ) / 3.0 ) * 6.0 - 3.0 ) - 1.0 ), 0.0, 1.0 ), s ) * v;
}


//--------------------------------
// Modelling 
//--------------------------------
vec2 map( vec3 pos ){  

    vec2 res = vec2( 1000000. , 0. );

    float n = pNoise( pos * 400.  + vec3( time ));
    float n2 = pNoise( pos * 100.  + vec3( time ));


    res = smoothU( res , vec2( length( pos ) - .04 , 1. + n + n2 ) , 0. );
    res.x += n * .005 + n2 * .01;

    return res;
    
}

//--------------------------------
// Modelling 
//--------------------------------
vec2 map2( vec3 pos ){  

    vec2 res = vec2( 1000000. , 0. );

    float n = pNoise( pos * 400. * ( 1. + .1 * sin( time * 20. ) )  + vec3( time ));
    float n2 = pNoise( pos * 100. * ( 1. + .3 * sin( time * 5. ) )  + vec3( time ));


    res = smoothU( res , vec2( length( pos ) - .04 , 1. ) , 0. );
    res.x += n * .005 + n2 * .01;

    res.x *= -1.;


    res = smoothU( res , vec2( length( pos ) - .02 , 4. )  , 0. ); 

    res = vec2( length( pos ) - .01 , 4. );

    return res;
    
}

// Calculates the normal by taking a very small distance,
// remapping the function, and getting normal for that
vec3 calcNormal2( in vec3 pos ){
    
  vec3 eps = vec3( 0.001, 0.0, 0.0 );
  vec3 nor = vec3(
      map2(pos+eps.xyy).x - map2(pos-eps.xyy).x,
      map2(pos+eps.yxy).x - map2(pos-eps.yxy).x,
      map2(pos+eps.yyx).x - map2(pos-eps.yyx).x );

  return normalize(nor);
}

vec2 calcIntersection2( in vec3 ro, in vec3 rd ){

    
    float h =  INTERSECTION_PRECISION*2.0;
    float t = 0.0;
    float res = -1.0;
    float id = -1.;
    
    for( int i=0; i< NUM_OF_TRACE_STEPS ; i++ ){
        
        if( h < INTERSECTION_PRECISION || t > MAX_TRACE_DISTANCE ) break;
       vec2 m = map2( ro+rd*t );
        h = m.x;
        t += h;
        id = m.y;
        
    }

    if( t < MAX_TRACE_DISTANCE ) res = t;
    if( t > MAX_TRACE_DISTANCE ) id =-1.0;
    
    return vec2( res , id );
    
}


$calcIntersection
$calcNormal
$calcAO


void main(){

  vec3 fNorm =  vNorm; //uvNormalMap( t_normal , vPos , vUv * 20. , vNorm , .4 * pain , .6 * pain * pain);

  vec3 ro = vPos;
  vec3 rd = normalize( vPos - vCam );

  vec3 p = vec3( 0. );
  vec3 col =  vec3( 0. );



  //col += fNorm * .5 + .5;

  vec3 refr = rd; //refract( rd , fNorm , 1. / (1.1 - .1 * pain ) );

  vec2 res = calcIntersection( ro , refr );

  vec3 lightDir = lightPos-vPos;
  vec3 refl = reflect( lightDir , fNorm );

  //col = texture2D( t_matcap , semLookup( refr , fNorm , modelViewMatrix , normalMatrix ) ).xyz;
 
  float fr = 1. + dot( fNorm, rd );
  col = vec3( .1 , 0.1 , 0.1 ); 
  float alpha =  .1;
  if( res.y > -.5 ){

    p = ro + refr * res.x;
    vec3 n = calcNormal( p );
    float ao = calcAO( p , n);



    col = mix( vec3(1.) , vec3( ao * ao * ao * ao * ao *ao ) , abs( sin( time * .1 ) + sin( time * .39) ));

    if( (res.y -1.) < 1.4 ){

    //col = vec3( 1. , 0., 0.);


      for( int  i = 0; i < 3; i++ ){

        vec3 ro2 = p;
        vec3 rd2 = refract( rd , n , .98 - .2 * (float( i ) / 3.) );

        vec2 res2 = calcIntersection2( ro2 , rd2 );

        vec3 c = vec3(1. ,0., 0.);


        if( i == 1 ){ c = c.yxy; };
        if( i == 2 ){ c = c.yyx; };

        if( res2.y > -.5 ){


          vec3 p2 = ro2 + rd2 * res2.x;
          vec3 n2 = calcNormal2( p2 );

          vec3 refr3 = refract( rd2 , n2 , .98 - .2 * (float( i ) / 3.) );
          

          if( res2.y > 3. ){
            col -= c * vec3( 1.,1. ,1. );
          }else{

            col *= normalize(refr3) * .5 + .5;

          }
        }

      }

    }

  }else{
    //discard;
  }

  //col = vec3( 1. ) - col;

  gl_FragColor = vec4( col , 1. );

}
