import 'package:flutter_sqlite_demo/app_config/text_config.dart';

class Person {

   int? id;

   String? name;

   int? age;

   String? address;

  Person({
    this.id,
    this.name,
    this.age,
    this.address,
  });

   Person personFromJson(Map<String, dynamic> json) => Person(
     id: json[TextConfig.personColumnId] as int?,
     name: json[TextConfig.personColumnName] as String?,
     age: json[TextConfig.personColumnAge] as int?,
     // address: json[TextConfig.personColumnAddress] as String?,
   );

   Map<String, dynamic> personToJson(Person instance) =>
       <String, dynamic>{
         TextConfig.personColumnId: instance.id,
         TextConfig.personColumnName: instance.name,
         TextConfig.personColumnAge: instance.age,
         // TextConfig.personColumnAddress: instance.address,
       };
}
