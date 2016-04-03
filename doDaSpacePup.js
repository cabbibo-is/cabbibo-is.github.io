
var G = {}

G.loading = {

      loaded:0,
      neededToLoad:0

    },

G.shaders = new ShaderLoader( 'shaders' , 'shaders/chunks' );

G.init = function(){

  G.uniforms = {
    time: {type:"f", value:0},
    iModelMat:{type:"m4", value:new THREE.Matrix4()},
    t_cube:{type:"t", value: null },
    noiseSize1:{type:"f", value:1},
    noiseSize2:{type:"f", value:1},
  }

  G.uniforms.t_cube.value = G.skyMap;

  var ar = window.innerWidth / window.innerHeight;

  G.three = {

    scene           : new THREE.Scene(),
    camera          : new THREE.PerspectiveCamera( 40 , ar , .01 , 100 ),
    renderer        : new THREE.WebGLRenderer(),
    clock           : new THREE.Clock(),
    stats           : new Stats()

  }

  G.three.renderer.setSize( window.innerWidth, window.innerHeight );
  G.three.renderer.setClearColor( 0xffffff , 1 )
  G.three.renderer.domElement.id = "renderer"
  G.three.renderer.setPixelRatio(  2 );
  document.body.appendChild( G.three.renderer.domElement );

  G.three.stats.domElement.style.position = "absolute";
  G.three.stats.domElement.style.left = "0px";
  G.three.stats.domElement.style.bottom = "-30px";
  G.three.stats.domElement.style.zIndex = "999";
 // document.body.appendChild( G.three.stats.domElement );


  G.controls = new THREE.TrackballControls( G.three.camera );
  G.controls.noZoom = true;
  G.controls.noPan = true;
  G.controls.noRoll = true;
  G.three.camera.position.z = .3;

  G.doDaSpacePup();

  
}

G.animate = function(){

  requestAnimationFrame( G.animate );
  G.controls.update();

  G.uniforms.time.value += G.three.clock.getDelta();
  //G.sp.rotation.y += .01;
  //G.sp.rotation.x += .01;
  G.uniforms.iModelMat.value.getInverse( G.sp.matrixWorld );

  G.three.renderer.render( G.three.scene , G.three.camera );
  G.three.stats.update();

  
}

G.doDaSpacePup = function(){

  var mat = new THREE.ShaderMaterial({
    uniforms: G.uniforms,
    vertexShader:G.shaders.vs.trace,
    fragmentShader:G.shaders.fs.trace,
  });

  //var mat = new THREE.MeshNormalMaterial({
  //  side: THREE.DoubleSide
  //});
  

  var geo = new THREE.CylinderGeometry( 0,.1,.13,3,1);
  var geo = new THREE.IcosahedronGeometry(.05 ,4 );

  var mesh = new THREE.Mesh( geo , mat );
  //mesh.rotation.
  

  G.sp = mesh;
  G.three.scene.add( mesh );

}

