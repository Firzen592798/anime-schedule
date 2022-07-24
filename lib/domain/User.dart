class User{
  int _id;
  String _name;
  String _picture;

  User();

   Map<String, dynamic> toJson() => {
    'id': _id,
    'name': _name,
    'picture': _picture,
   };

   User.fromJson(Map<String, dynamic> json){
    _id = json['id'] ?? 0;
    _name = json['name'] ?? "";
    _picture = json['picture'] ?? null;
   }
  
  get id => this._id;

  set id( value) => this._id = value;

  String get name => this._name;

  set name( value) => this._name = value;

  String get picture => this._picture;

  set picture( value) => this._picture = value;
}