
uniform mat4 iModelMat;
uniform float time;
uniform float started;
uniform sampler2D t_audio;

uniform float life;
uniform float norm;
uniform float pain;
uniform float love;
uniform vec3 lightPos;



varying vec3 vPos;
varying vec3 vNorm;
varying vec3 vCam;

varying vec3 vMNorm;
varying vec3 vMPos;

varying vec2 vUv;
varying float vNoise;

varying vec3 vAudio;

$simplex




void main(){

  vUv = uv;

  vPos = position;
  vNorm = normal;

  vMNorm = normalMatrix * normal;
  vMPos = (modelMatrix * vec4( vPos , 1. )).xyz;

  vCam   = ( iModelMat * vec4( cameraPosition , 1. ) ).xyz;

  vNoise = snoise( vMPos  * 10. + vec3(0. , time , 0.));


  // Use this position to get the final position 
  gl_Position = projectionMatrix * modelViewMatrix * vec4( vPos , 1.);

}