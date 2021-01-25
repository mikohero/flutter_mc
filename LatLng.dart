class MyLatLng {
  String file;
  String lat;
  String lng;
  MyLatLng(this.file,this.lat,this.lng);

  @override
  String toString() {
    return '{file:${this.file},lat:${this.lat},lng:${this.lng}}';
  }
  Map toJson() => {
    'file': file,
    'lat': lat,
    'lng': lng,
  };

}