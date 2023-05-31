import 'package:flutter/material.dart';

class StudentModel {
  String? studentName;
  String? studentClass;
  String? studentAdress;
  String? studentPhone;
  String? studentPhone2;
  String? chauffeurName;
  String? hostessName;
  String? carPlate;

  StudentModel({this.studentName, this.studentClass, this.studentAdress, this.studentPhone, this.studentPhone2, this.chauffeurName, this.hostessName, this.carPlate});

  StudentModel.fromJson(Map<String, dynamic> json) {
    studentName = json['studentName'];
    studentClass = json['studentClass'];
    studentAdress = json['studentAdress'];
    studentPhone = json['studentPhone'];
    studentPhone2 = json['studentPhone2'];
    chauffeurName = json['chauffeurName'];
    hostessName = json['hostessName'];
    carPlate = json['carPlate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['studentName'] = studentName;
    data['studentClass'] = studentClass;
    data['studentAdress'] = studentAdress;
    data['studentPhone'] = studentPhone;
    data['studentPhone2'] = studentPhone2;
    data['chauffeurName'] = chauffeurName;
    data['hostessName'] = hostessName;
    data['carPlate'] = carPlate;
    return data;
  }
}

class StudentExcelModel {
  String? serviceNo;
  String? route;
  String? carPlate;
  String? distance;
  String? chauffeurName;
  String? chauffeurPhone;
  String? hostessName;
  String? hostessPhone;
  String? studentName;
  String? studentClass;
  String? boardingAdress;
  String? landingAdress;
  String? studentPhone;
  String? parentType1;
  String? parentName1;
  String? parentPhone1;
  String? parentType2;
  String? parentName2;
  String? parentPhone2;
  String? parentType3;
  String? parentName3;
  String? parentPhone3;

  StudentExcelModel(
      {this.serviceNo,
      this.route,
      this.carPlate,
      this.distance,
      this.chauffeurName,
      this.chauffeurPhone,
      this.hostessName,
      this.hostessPhone,
      this.studentName,
      this.studentClass,
      this.boardingAdress,
      this.landingAdress,
      this.studentPhone,
      this.parentType1,
      this.parentName1,
      this.parentPhone1,
      this.parentType2,
      this.parentName2,
      this.parentPhone2,
      this.parentType3,
      this.parentName3,
      this.parentPhone3});

  StudentExcelModel.fromJson(Map<String, dynamic> json) {
    serviceNo = json['serviceNo'];
    route = json['route'];
    carPlate = json['carPlate'];
    distance = json['distance'];
    chauffeurName = json['chauffeurName'];
    chauffeurPhone = json['chauffeurPhone'];
    hostessName = json['hostessName'];
    hostessPhone = json['hostessPhone'];
    studentName = json['studentName'];
    studentClass = json['studentClass'];
    boardingAdress = json['boardingAdress'];
    landingAdress = json['landingAdress'];
    studentPhone = json['studentPhone'];
    parentType1 = json['parentType1'];
    parentName1 = json['parentName1'];
    parentPhone1 = json['parentPhone1'];
    parentType2 = json['parentType2'];
    parentName2 = json['parentName2'];
    parentPhone2 = json['parentPhone2'];
    parentType3 = json['parentType3'];
    parentName3 = json['parentName3'];
    parentPhone3 = json['parentPhone3'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['serviceNo'] = serviceNo;
    data['route'] = route;
    data['carPlate'] = carPlate;
    data['distance'] = distance;
    data['chauffeurName'] = chauffeurName;
    data['chauffeurPhone'] = chauffeurPhone;
    data['hostessName'] = hostessName;
    data['hostessPhone'] = hostessPhone;
    data['studentName'] = studentName;
    data['studentClass'] = studentClass;
    data['boardingAdress'] = boardingAdress;
    data['landingAdress'] = landingAdress;
    data['studentPhone'] = studentPhone;
    data['parentType1'] = parentType1;
    data['parentName1'] = parentName1;
    data['parentPhone1'] = parentPhone1;
    data['parentType2'] = parentType2;
    data['parentName2'] = parentName2;
    data['parentPhone2'] = parentPhone2;
    data['parentType3'] = parentType3;
    data['parentName3'] = parentName3;
    data['parentPhone3'] = parentPhone3;
    return data;
  }
}

class BelediyeModel {
  String? title;
  IconData? icon;
  String? content1;
  String? content2;
  String? content3;

  BelediyeModel({this.title, this.icon, this.content1, this.content2, this.content3});
}
