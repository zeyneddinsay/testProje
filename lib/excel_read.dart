import 'package:excel_deneme/model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';

class ExcelOkuma extends StatefulWidget {
  const ExcelOkuma({super.key});

  @override
  State<ExcelOkuma> createState() => _ExcelOkumaState();
}

class _ExcelOkumaState extends State<ExcelOkuma> {
  List<StudentModel> dataStudent = [];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
            onPressed: () async {
              readExcel();
            },
            child: Text("excelden oku")),
        ElevatedButton(
          onPressed: () async {
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
                debugPrint("************************  table ******************************");
                print(table); //sheet Name
                debugPrint("**************************  table ****************************");
                debugPrint("**************************  maxcols ****************************");

                print(excel.tables[table]!.maxCols);
                debugPrint("**************************  maxcols ****************************");
                debugPrint("**************************  maxrows ****************************");

                print(excel.tables[table]!.maxRows);
                debugPrint("**************************  maxrows ****************************");

                for (var row in excel.tables[table]!.rows) {
                  var adSoyad = await row[1]!.value;

                  debugPrint("**************************  ad ****************************");

                  // var ad = adSoyadArray[0];
                  print('${adSoyad}');

                  debugPrint("**************************  ad ****************************");
                  debugPrint("**************************  soyad ****************************");

                  // var soyad = adSoyadArray[1];
                  // print('${soyad}');

                  debugPrint("**************************  soyad ****************************");

                  debugPrint("**************************  row ****************************");
                  print('${row}');
                  debugPrint("**************************  row ****************************");
                }
              }
            }
          },
          // onPressed: () async {
          //   FilePickerResult? result = await FilePicker.platform.pickFiles();

          //   if (result != null) {
          //     PlatformFile file = result.files.first;
          //     if (file.extension == 'xlsx') {
          //       var bytes = File(file.path!).readAsBytesSync();
          //       var excel = Excel.decodeBytes(bytes);
          //       for (var table in excel.tables.keys) {
          //         debugPrint(table); // sayfa adını yazdırır

          //         var sheet = excel.tables[table]!;
          //         for (var row in sheet.rows) {
          //           debugPrint(row.join(',')); // satırın verilerini yazdırır
          //         }
          //       }
          //       // dosya bir Excel dosyasıdır, işleme devam edin
          //     } else {
          //       // dosya bir Excel dosyası değildir, kullanıcıya hata mesajı gösterin
          //     }
          //     // dosya işlemlerini burada yapın
          //   } else {
          //     // kullanıcı herhangi bir dosya seçmedi
          //   }
          // },
          child: Text('Excel Dosyası Seç'),
        )
      ],
    );
  }

  Future<void> pickAndReadExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      final filePath = result.files.single.path!;
      final bytes = result.files.single.bytes!;
      final excel = Excel.decodeBytes(bytes);
      for (var table in excel.tables.keys) {
        print(table); // sayfa adını yazdırır

        var sheet = excel.tables[table]!;
        for (var row in sheet.rows) {
          print(row.join(',')); // satırın verilerini yazdırır
        }
      }

      // Excel dosyasını burada işleyin
    }
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
        debugPrint("************************  table ******************************");
        print(table); //sheet Name
        debugPrint("**************************  table ****************************");
        debugPrint("**************************  maxcols ****************************");
        print(excel.tables[table]!.maxCols);
        debugPrint("**************************  maxcols ****************************");
        debugPrint("**************************  maxrows ****************************");
        print(excel.tables[table]!.maxRows);
        debugPrint("**************************  maxrows ****************************");

        for (var i = 6; i < excel.tables[table]!.rows.length; i++) {
          var row = excel.tables[table]!.rows[i];

          SharedString chauffeurName=excel.tables[table]?.rows[2][2]?.value;
          SharedString hostessName=excel.tables[table]?.rows[3][2]?.value;
          SharedString carPlate=            excel.tables[table]?.rows[1][4]?.value;


          SharedString? studentName = row[1]?.value;
          SharedString? studentClass = row[2]?.value;
          SharedString? studentAdress = row[3]?.value;
          SharedString? studentPhone= row[4]?.value;
          SharedString? studentPhone2 = row[5]?.value;



          if (studentName == null) continue;
          if (studentClass == null) continue;
          if (studentAdress == null) continue;
          if (studentPhone == null) continue;
          if (studentPhone2 == null) continue;
          if (chauffeurName == null) continue;
          if (hostessName == null) continue;
          if (carPlate == null) continue;


          



          dataStudent.add(StudentModel(
            carPlate:carPlate.node.text,
            studentName: studentName.node.text,
            studentClass: studentClass.node.text,
            studentAdress: studentAdress.node.text,
            studentPhone: studentPhone.node.text,
            studentPhone2: studentPhone2.node.text,
            chauffeurName: chauffeurName.node.text,
            hostessName: hostessName.node.text,
          ));
          // print(studentName);
        }
        debugPrint(dataStudent.length.toString());
        for (var x in dataStudent) {
          debugPrint(x.studentName);
          debugPrint(x.studentClass);
          debugPrint(x.studentAdress);
          debugPrint(x.studentPhone);
          debugPrint(x.studentPhone2);
        }

        for (var row in excel.tables[table]!.rows) {
          // dataStudent[i].carPlate=row[]!.value;
          // dataStudent[i].carPlate=row[]!.value;

          // var adSoyad = await row[1]!.value;

          // debugPrint("**************************  ad ****************************");

          // // var ad = adSoyadArray[0];
          // print('${adSoyad}');

          // debugPrint("**************************  ad ****************************");
          // debugPrint("**************************  soyad ****************************");

          // // var soyad = adSoyadArray[1];
          // // print('${soyad}');

          // debugPrint("**************************  soyad ****************************");

          // debugPrint("**************************  row ****************************");
          // print('${row}');
          // debugPrint("**************************  row ****************************");
        }
      }
    }
  }

}
