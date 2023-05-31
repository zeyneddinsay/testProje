import 'package:excel_deneme/model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:get/get.dart';

class StudentExcel extends StatefulWidget {
  const StudentExcel({super.key});

  @override
  State<StudentExcel> createState() => _StudentExcelState();
}

class _StudentExcelState extends State<StudentExcel> {
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

  RxList<StudentExcelModel> dataStudent = <StudentExcelModel>[].obs;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
            onPressed: () {
              readExcel();
            },
            child: Text("Oku"))
      ],
    );
  }

  readExcel() async {
    /// Use FilePicker to pick files in Flutter Web

    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );

    /// file might be picked

    if (pickedFile != null) {
      var bytes = pickedFile.files.single.bytes;
      var excel = Excel.decodeBytes(bytes!);

      for (var table in excel.tables.keys) {
        for (var i = 10; i < excel.tables[table]!.rows.length; i++) {
          var row = excel.tables[table]!.rows[i];

          serviceNo = excel.tables[table]?.rows[0][1]?.value.toString();
          route = excel.tables[table]?.rows[1][1]?.value.toString();
          carPlate = excel.tables[table]?.rows[2][1]?.value.toString();
          distance = excel.tables[table]?.rows[3][1]?.value.toString();
          chauffeurName = excel.tables[table]?.rows[4][1]?.value.toString();
          chauffeurPhone = excel.tables[table]?.rows[5][1]?.value.toString();
          hostessName = excel.tables[table]?.rows[6][1]?.value.toString();
          hostessPhone = excel.tables[table]?.rows[7][1]?.value.toString();

          studentName = row[0]?.value.toString();
          studentClass = row[1]?.value.toString();
          boardingAdress = row[2]?.value.toString();
          landingAdress = row[3]?.value.toString();
          studentPhone = row[4]?.value.toString();
          parentType1 = row[5]?.value.toString();
          parentName1 = row[6]?.value.toString();
          parentPhone1 = row[7]?.value.toString();
          parentType2 = row[8]?.value.toString();
          parentName2 = row[9]?.value.toString();
          parentPhone2 = row[10]?.value.toString();
          parentType3 = row[11]?.value.toString();
          parentName3 = row[12]?.value.toString();
          parentPhone3 = row[13]?.value.toString();

          dataStudent.add(StudentExcelModel(
            serviceNo: serviceNo ?? "",
            route: route ?? "",
            carPlate: carPlate ?? "",
            distance: distance ?? "",
            chauffeurName: chauffeurName ?? "",
            chauffeurPhone: chauffeurPhone ?? "",
            hostessName: hostessName ?? "",
            hostessPhone: hostessPhone ?? "",
            studentName: studentName ?? "",
            studentClass: studentClass ?? "",
            boardingAdress: boardingAdress ?? "",
            landingAdress: landingAdress ?? "",
            studentPhone: studentPhone ?? "",
            parentType1: parentType1 ?? "",
            parentName1: parentName1 ?? "",
            parentPhone1: parentPhone1 ?? "",
            parentType2: parentType2 ?? "",
            parentName2: parentName2 ?? "",
            parentPhone2: parentPhone2 ?? "",
            parentType3: parentType3 ?? "",
            parentName3: parentName3 ?? "",
            parentPhone3: parentPhone3 ?? "",
          ));
        }
      }
    }
    for (var x in dataStudent) {
      print(x.studentName);
    }
  }
}
