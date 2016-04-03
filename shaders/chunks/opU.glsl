// checks to see which intersection is closer
// and makes the y of the vec2 be the proper id
vec2 opU( vec2 d1, vec2 d2 ){
    
  return (d1.x<d2.x) ? d1 : d2;
    
}
