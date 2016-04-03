function RotateControls(object){
  
  this.radius = 1;
  this.height = .0;
  this.target = new THREE.Vector3();
  this.velocity = .1;
  this.angle = 0;
  this.object = object;


}

RotateControls.prototype.update = function(){

  this.angle += this.velocity;
  this.velocity *= .95;

  this.object.position.x = Math.sin( this.angle );
  this.object.position.z = Math.cos( this.angle );
  this.object.position.y = 0;

  this.object.position.multiplyScalar( this.radius );

  this.object.position.y = this.height;

  this.object.lookAt( this.target );


}