function beginLoad(){
  loadShaders();
  loadAudio();
  loadCubeMap();
}

function loadShaders(){

  //shaders.load( 'ss-curlFront'    , 'sim'    , 'simulation' );

  G.loading.neededToLoad ++;

  G.shaders.load( 'fs-trace'  , 'trace' , 'fragment' );
  G.shaders.load( 'vs-trace'  , 'trace' , 'vertex'   );

  
  G.shaders.shaderSetLoaded = function(){
    onLoad();
  }

}



function loadImage(url){

  G.loading.neededToLoad ++;
  var r = THREE.RepeatWrapping;

  var t = THREE.ImageUtils.loadTexture(url, r , onLoad, onError);
  t.wrapT = t.wrapS = THREE.RepeatWrapping;
  return t;

}

function loadCubeMap(){

  G.loading.neededToLoad ++;
  G.loading.neededToLoad ++;
  G.loading.neededToLoad ++;
  G.loading.neededToLoad ++;

  var path = "milky/dark-s_";
  var format = '.jpg';
  var urls = [
      path + 'px' + format, path + 'nx' + format,
      path + 'py' + format, path + 'ny' + format,
      path + 'pz' + format, path + 'nz' + format
    ];







  var loader = new THREE.CubeTextureLoader();
  //loader.onLoad = 




  var path = "skybox/";
  var format = '.jpg';
  var urls = [
      path + 'px' + format, path + 'nx' + format,
      path + 'py' + format, path + 'ny' + format,
      path + 'pz' + format, path + 'nz' + format
    ];
  var reflectionCube = loader.load( urls ,function(){
    console.log("HAHA");
    onLoad();
  });
  reflectionCube.format = THREE.RGBFormat;
  //G.cubeMap = reflectionCube;
  G.skyMap = reflectionCube;




  var path = "park/";
  var format = '.jpg';
  var urls = [
      path + 'posx' + format, path + 'negx' + format,
      path + 'posy' + format, path + 'negy' + format,
      path + 'posz' + format, path + 'negz' + format
    ];


  var parkCube = loader.load( urls ,function(){
    console.log("HAHA");
    onLoad();
  });
  parkCube.format = THREE.RGBFormat;
  G.parkMap = parkCube;


  var path = "castle/";
  var format = '.jpg';
  var urls = [
      path + 'px' + format, path + 'nx' + format,
      path + 'py' + format, path + 'ny' + format,
      path + 'pz' + format, path + 'nz' + format
    ];


  var castleCube = loader.load( urls ,function(){
    console.log("HAHA");
    onLoad();
  });
  castleCube.format = THREE.RGBFormat;
  G.castleMap = castleCube;


  var path = "pisa/";
  var format = '.png';
  var urls = [
      path + 'px' + format, path + 'nx' + format,
      path + 'py' + format, path + 'ny' + format,
      path + 'pz' + format, path + 'nz' + format
    ];


  var pisaCube = loader.load( urls ,function(){
    console.log("HAHA");
    onLoad();
  });
  pisaCube.format = THREE.RGBFormat;
  G.pisaMap = pisaCube;
}


function loadAudio(){

  //loadBuffer( "loveLoopBuffer"  , "audio/love.mp3"      );
  //loadBuffer( "painLoopBuffer"  , "audio/pain.mp3"      );
  //loadBuffer( "normLoopBuffer"  , "audio/norm.mp3"      );
//
  //loadBuffer( "clickNoteBuffer" , "audio/switch.mp3"    );
  //loadBuffer( "startNoteBuffer" , "audio/startNote.mp3" );
  //loadBuffer( "jestNoteBuffer"  , "audio/jest.mp3" );



}

function loadBuffer(name , bufferFile){

  var aBuff = new AudioBuffer( G.audio , bufferFile);
  G[name] = aBuff;
  G.loading.neededToLoad += 1;
  aBuff.addLoadEvent(function(){
    onLoad();
  })

}

function onLoad(){

  G.loading.loaded ++;

  console.log( G.loading );


  if( G.loading.loaded == G.loading.neededToLoad ){

    finishedLoading();

  }

}

// TODO: these catch?
function onProgress(e){
  console.log( e );
}

function onError(e){
  console.log( e );
}

function finishedLoading(){
  G.init(); 
  G.animate();
}