
uniform float time;

uniform samplerCube t_cube;

uniform sampler2D t_matcap;
uniform sampler2D t_normal;
uniform sampler2D t_color;

uniform mat4 modelViewMatrix;
uniform mat3 normalMatrix;

uniform float noiseSize1;
uniform float noiseSize2;


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
const float INTERSECTION_PRECISION = 0.0001;        // precision of the intersection
const int NUM_OF_TRACE_STEPS = 50;
const float PI = 3.14159;

const int NUM_COL_RAYS = 3;



$smoothU
$opU
$pNoise



vec3 vHash( vec3 x )
{
  x = vec3( dot(x,vec3(127.1,311.7, 74.7)),
        dot(x,vec3(269.5,183.3,246.1)),
        dot(x,vec3(113.5,271.9,124.6)));

  return fract(sin(x)*43758.5453123);
}



// returns closest, second closest, and cell id
vec3 voronoi( in vec3 x )
{
    vec3 p = floor( x );
    vec3 f = fract( x );

  float id = 0.0;
    vec2 res = vec2( 100.0 );
    for( int k=-1; k<=1; k++ )
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        vec3 b = vec3( float(i), float(j), float(k) );
        vec3 r = vec3( b ) - f + vHash( p + b );
        float d = dot( r, r );

        if( d < res.x )
        {
      id = dot( p+b, vec3(1.0,57.0,113.0 ) );
            res = vec2( d, res.x );     
        }
        else if( d < res.y )
        {
            res.y = d;
        }
    }

    return vec3( sqrt( res ), abs(id) );
}



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


float fNoise( vec3 pos ){
    float n = pNoise( pos * 200. * noiseSize1 + vec3( time ));
    float n2 = pNoise( pos * 40. * noiseSize2 + vec3( time ));

    return n * .005 + n2 * .01;
}



//--------------------------------
// Modelling 
//--------------------------------
vec2 map( vec3 pos ){  

    vec2 res = vec2( 1000000. , 0. );


    res = smoothU( res , vec2( length( pos ) - .04 , 1. ) , 0. );
    res.x += fNoise(pos);

    return res;
    
}

//--------------------------------
// Modelling 
//--------------------------------
vec2 map2( vec3 pos ){  

    vec2 res = vec2( 1000000. , 0. );


    res = smoothU( res , vec2( length( pos ) - .04 , 1. ) , 0. );
    float n = fNoise(pos);
    res.x += n;

    res.x *= -1.;


    res = smoothU( res , vec2( length( pos ) - .01 - n * .5 , 4. )  , 0. ); 
    //res.x -= n * .2;

    //res = vec2( length( pos ) - .01 , 4. );

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


vec3 Gamma(vec3 value, float param)
{
    return vec3(pow(abs(value.r), param),pow(abs(value.g), param),pow(abs(value.b), param));
}

void main(){

  vec3 fNorm =  vNorm; //uvNormalMap( t_normal , vPos , vUv * 20. , vNorm , .4 * pain , .6 * pain * pain);

  vec3 ro = vPos;
  vec3 rd = normalize( vPos - vCam );

  vec3 p = vec3( 0. );
  vec3 col =  vec3( 0. );

  


  //col += fNorm * .5 + .5;

  vec3 refr = rd; //refract( rd , fNorm , 1. / (1.1 - .1 * pain ) );

  vec2 res = calcIntersection( ro , refr );


  vec3 refl = reflect( rd , fNorm );

  //col = texture2D( t_matcap , semLookup( refr , fNorm , modelViewMatrix , normalMatrix ) ).xyz;
 
  float fr = 1. + dot( fNorm, rd );

  float outerNoise = fNoise( ro * .3 );
  col = vec3( .1 , 0.1 , 0.1 ); 

  col = textureCube( t_cube , refl ).xyz;
  float alpha =  .1;
  
  if( res.y > -.5 ){

    p = ro + refr * res.x;
    vec3 n = calcNormal( p );
    //float ao = calcAO( p , n);

    refl = reflect( rd , n );


    col = textureCube( t_cube , refl ).xyz;



    //col = vec3(0.);// mix( vec3(1.) , vec3( ao * ao * ao * ao * ao *ao ) , abs( sin( time * .1 ) + sin( time * .39) ));

    if( (res.y -1.) < 4. ){

    //col = vec3( 1. , 0., 0.);

      vec3 refrCol = vec3(0.);

      for( int  i = 0; i < NUM_COL_RAYS; i++ ){

        
        vec3 rd2 = refract( rd , n , .98 - .04 * (float( i ) / float(NUM_COL_RAYS)) );
        vec3 ro2 = p + rd2 * .02;
        vec2 res2 = calcIntersection2( ro2 , rd2 );

        vec3 c = vec3(1. ,0., 0.);

        c = hsv( float( i )/float(NUM_COL_RAYS) , 1. , 1. );




        //if( i == 1 ){ c = c.yxy; };
        //if( i == 2 ){ c = c.yyx; };

        if( res2.y > -.5 ){


          vec3 p2 = ro2 + rd2 * res2.x;
          vec3 n2 = calcNormal2( p2 );

          vec3 refr3 = refract( rd2 , n2 , .98 - .04 * (float( i ) / float(NUM_COL_RAYS)) );
          

          if( res2.y > 3. ){
            
            refrCol += c *  1.+dot( n2 , rd2);// * c * textureCube( t_cube , normalize( n2 )).xyz ;;
          
          }else{
           // col = refr3; //vec3( 1. , 0. , 0. );
            refrCol += c * textureCube( t_cube , normalize( refr3 )).xyz ;

          }
        }



      }

      col = mix( refrCol , col  , .2  );
      //col = vec3( ao * ao * ao * ao );

    }

  }else{

    col = textureCube( t_cube , normalize( rd )).xyz;

    col = mix( vec3(1.) , col , min(1. , (1.-fr)) );
    col += max( 0. ,( outerNoise - .01 )) * 100. * min(1. , (1.-fr));
    //col = vec3( 0. );
    //discard;
  }

  //col = vec3( 1. ) - col;

  gl_FragColor = vec4( col , 1. );

}
