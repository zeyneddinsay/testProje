import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:portakilweb/api/controller/google_maps_controller/direction_controller.dart';
import 'package:portakilweb/api/controller/google_maps_controller/model/direction_model.dart';
import 'package:portakilweb/api/model/messagemodel.dart';
import 'package:portakilweb/api/model/student_model.dart';
import 'package:portakilweb/init/app_colors_dark.dart';
import 'package:portakilweb/init/debounce.dart';
import 'package:portakilweb/init/hover_widget_color.dart';
import 'package:portakilweb/init/menu_button_color.dart';
import 'package:portakilweb/pages/88_google_map_web/student_service_planning/controller/student_service_planning_controller.dart';
import 'package:portakilweb/pages/88_google_map_web/student_service_planning/model/student_service_planning_model.dart';
import 'package:portakilweb/tools/text/x_text.dart';
import 'package:portakilweb/tools/text/x_text_poppins.dart';
import 'package:portakilweb/tools/text_edit/textfield_focus.dart';
import 'package:portakilweb/tools/text_edit/textfield_only.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class GoogleMapWebStudentAllAddressSelect extends StatefulWidget {
  final int studentAdressID;

  final Key instanceTag;

  const GoogleMapWebStudentAllAddressSelect({
    Key? key,
    required this.instanceTag,
    required this.studentAdressID,
  }) : super(key: key);

  @override
  State<GoogleMapWebStudentAllAddressSelect> createState() => _GoogleMapWebStudentAllAddressSelectState();
}

class _GoogleMapWebStudentAllAddressSelectState extends State<GoogleMapWebStudentAllAddressSelect> {
  Rx<StudentAddressModel>? model = StudentAddressModel().obs;
  RxInt selectedStudentAddressID = 0.obs;
  List<ServiceWeekStudentListV2Model> filteredList = [];

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  StudentServicePlanningController? studentServicePlanningController;

  var f = NumberFormat.currency(locale: "tr_TR", symbol: "", decimalDigits: 0);

  ScrollController horizontalScroll = ScrollController();
  ScrollController verticalScroll = ScrollController();
  ScrollController horizontalScrolls = ScrollController();
  TextEditingController searchTextEditingControl = TextEditingController();
  TextEditingController studentSearchTextEditingControl = TextEditingController();

  String? schoolName;
  String? studentName;

  TextEditingController addressNameTextEditingControl = TextEditingController();

  TextEditingController addressTextEditingControl = TextEditingController();
  TextEditingController districtTextEditingControl = TextEditingController();
  TextEditingController cityTextEditingControl = TextEditingController();
  TextEditingController addressLatTextEditingControl = TextEditingController();
  TextEditingController addressLngTextEditingControl = TextEditingController();

  Completer<GoogleMapController> googleMapController = Completer();
  DirectionController? directionController;
  RxList<GoogleGeocodeListModel> googleGeocodeList = <GoogleGeocodeListModel>[].obs;
  LatLng? latLng;
  List<LatLng> polylineCordinates = [];
  bool isHover = false;
  BitmapDescriptor schoolIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor studentIcon = BitmapDescriptor.defaultMarker;
  RxBool isDrawRoute = true.obs;

  String apiKey = 'AIzaSyDXl2149XIAT3DoD-V65X8PGqanj8lI_d8';

  // Future<Position> getCurrentLocation() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     return Future.error('Lokasyon servisleri kapalı');
  //   }
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return Future.error('Konum izni reddedildi');
  //     }
  //   }
  //   if (permission == LocationPermission.deniedForever) {
  //     return Future.error('Konum izni reddedildi (sürekli reddedildi)');
  //   }
  //   return await Geolocator.getCurrentPosition();
  // }

  late double lat;
  late double lng;
  @override
  void initState() {
    studentServicePlanningController = Get.find(tag: widget.instanceTag.toString());

    setCustomMarkerIcon();

    directionController = Get.put(DirectionController(), tag: "direction");

    searchTextEditingControl.addListener(() {
      EasyDebounce.debounce('debouncer2', const Duration(seconds: 2), () async {
        dataLoad(searchTextEditingControl.text);
      });
    });
    studentSearchTextEditingControl.addListener(() {
      EasyDebounce.debounce('debouncer2', const Duration(seconds: 2), () async {
        filterList(studentSearchTextEditingControl.text); // Arama kutusundaki değere göre liste filtreleme fonksiyonu
      });
    });

    firstLoad();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToIndex();
    });

    super.initState();
  }

  void filterList(String searchValue) {
    // Arama değeri boş ise tüm liste gösterilsin
    if (searchValue.isEmpty) {
      setState(() {
        studentServicePlanningController!.adressSelectedListAdd();
      });
      return;
    }

    // Arama değeri boş değilse, listenin filtreleneceği kriterleri uygulayın
    setState(() {
      studentServicePlanningController!.newServiceWeekStudentListSelected.clear();
      studentServicePlanningController!.newServiceWeekStudentListSelected.addAll(studentServicePlanningController!.newServiceStudentList.where((item) {
        // Arama değeri ile öğe adını karşılaştırın (büyük/küçük harfe duyarlı olmayacak şekilde)
        return item.studentName!.toLowerCase().contains(searchValue.toLowerCase());
      }));
    });
  }

  firstLoad() async {
    studentServicePlanningController!.adressSelectedListAdd();
    ServiceWeekStudentListV2Model x = studentServicePlanningController!.newServiceWeekStudentListSelected.firstWhere((element) => element.studentAddressID == widget.studentAdressID);

    model!.value = StudentAddressModel(
      studentAddressID: x.studentAddressID,
      studentID: x.studentID,
      addressName: x.addressName,
      city: x.city,
      district: x.district,
      address: x.address,
      locationLat: x.locationLat,
      locationLng: x.locationLng,
      distance: x.distance!.toDouble(),
      isPassive: false,
      defaultAddress: true,
      recordUser: "",
      schoolMeter: x.distance!.toDouble(),
      price: 0.0,
    );
    selectedStudentAddressID.value = model!.value.studentAddressID!;
    studentName = studentServicePlanningController!.newServiceWeekStudentListSelected.firstWhere((element) => element.studentAddressID == widget.studentAdressID).studentName!;
    schoolName = studentServicePlanningController!.newServiceWeekStudentListSelected.firstWhere((element) => element.studentAddressID == widget.studentAdressID).schoolName!;

    addressNameTextEditingControl.text = model!.value.addressName!;
    addressTextEditingControl.text = model!.value.address!;
    districtTextEditingControl.text = model!.value.district!;
    cityTextEditingControl.text = model!.value.city!;
    addressLatTextEditingControl.text = model!.value.locationLat!;
    addressLngTextEditingControl.text = model!.value.locationLng!;
    await schoolDataLoad(studentServicePlanningController!.newServiceWeekStudentListSelected.firstWhere((element) => element.studentAddressID == widget.studentAdressID).schoolID.toString());
    if (model!.value.locationLat!.isNotEmpty && model!.value.locationLng!.isNotEmpty) {
      setStudentLocationMarker();
    }
  }

  setStudentMarker() {
    if (model!.value.locationLat!.isNotEmpty && model!.value.locationLng!.isNotEmpty) {
      addressLat.value = model!.value.locationLat!;
      addressLng.value = model!.value.locationLng!;

      directionController!.setStudentLocation(double.parse(model!.value.locationLat!), double.parse(model!.value.locationLng!));
      directionController!.setMarkerPoint(double.parse(model!.value.locationLat!), double.parse(model!.value.locationLng!));
      directionController!.setMarkerRx(Marker(
        markerId: MarkerId(model!.value.locationLat!.toString()),
        position: LatLng(double.parse(model!.value.locationLat!), double.parse(model!.value.locationLng!)),
        infoWindow: const InfoWindow(
          title: "Konum",
          snippet: "Öğrenci Konumu",
        ),
        zIndex: 1,
        draggable: true,
        onDrag: (value) {
          debugPrint("onDrag, $value");
          setLatLongPoint(value);
        },
        icon: studentIcon,
      ));
      setLatLongPoint(LatLng(double.parse(model!.value.locationLat!), double.parse(model!.value.locationLng!)));
    } else {
      // getCurrentLocation().then((value) {
      //   lat = value.latitude;
      //   lng = value.longitude;
      //   directionController!.setMarkerPoint(lat, lng);
      // });
    }
  }

  void setLatLongPoint(LatLng latLng) {
    if (model!.value.address!.isNotEmpty) {
      addressLat.value = latLng.latitude.toString();
      addressLng.value = latLng.longitude.toString();
      directionController!.setMarkerPoint(latLng.latitude, latLng.longitude);
      dataLoadGoogleGeocode(latLng.latitude.toString(), latLng.longitude.toString());
    } else {
      addressLat.value = latLng.latitude.toString();
      addressLng.value = latLng.longitude.toString();
      directionController!.setMarkerPoint(latLng.latitude, latLng.longitude);
      dataLoadGoogleGeocode(latLng.latitude.toString(), latLng.longitude.toString());
    }
  }

  setModelToController() {
    studentName = studentServicePlanningController!.newServiceWeekStudentListSelected.firstWhere((element) => element.studentAddressID == selectedStudentAddressID.value).studentName!;
    schoolName = studentServicePlanningController!.newServiceWeekStudentListSelected.firstWhere((element) => element.studentAddressID == selectedStudentAddressID.value).schoolName!;
    addressNameTextEditingControl.text = model!.value.addressName!;

    addressTextEditingControl.text = model!.value.address!;
    districtTextEditingControl.text = model!.value.district!;
    cityTextEditingControl.text = model!.value.city!;
    addressLatTextEditingControl.text = model!.value.locationLat!;
    addressLngTextEditingControl.text = model!.value.locationLng!;
  }

  // Future<void> firstLoad() async {
  //   if (widget.studentLat.isEmpty && widget.studentLng.isEmpty && widget.address.isNotEmpty) {
  //     searchTextEditingControl.text = widget.address;
  //     dataLoad(widget.address);
  //   }
  //   await schoolDataLoad();

  //   if (widget.studentLat.isNotEmpty && widget.studentLng.isNotEmpty) {
  //     addressLat.value = widget.studentLat;
  //     addressLng.value = widget.studentLng;
  //     debugPrint("widget.studentLat, ${widget.studentLat}");
  //     debugPrint("widget.studentLng, ${widget.studentLng}");
  //     directionController!.setStudentLocation(double.parse(widget.studentLat), double.parse(widget.studentLng));
  //     directionController!.setMarkerPoint(double.parse(widget.studentLat), double.parse(widget.studentLng));
  //     directionController!.setMarkerRx(Marker(
  //       markerId: MarkerId(widget.studentLat.toString()),
  //       position: LatLng(double.parse(widget.studentLat), double.parse(widget.studentLng)),
  //       infoWindow: const InfoWindow(
  //         title: "Konum",
  //         snippet: "Öğrenci Konumu",
  //       ),
  //       zIndex: 1,
  //       draggable: true,
  //       onDrag: (value) {
  //         debugPrint("onDrag, $value");
  //         setLatLongPoint(value);
  //       },
  //       icon: studentIcon,
  //     ));
  //   } else {
  //     // getCurrentLocation().then((value) {
  //     //   lat = value.latitude;
  //     //   lng = value.longitude;
  //     //   directionController!.setMarkerPoint(lat, lng);
  //     // });
  //   }
  // }

  Future<void> schoolDataLoad(String schoolID) async {
    await directionController!.getSchoolLatLngDistance(schoolID);
    directionController!.setMarkerRx(Marker(
      markerId: const MarkerId("School"),
      position: LatLng(directionController!.schoolLocation.value.latitude, directionController!.schoolLocation.value.longitude),
      infoWindow: InfoWindow(title: directionController!.schoolLatLngDistanceModel.value.schoolName!),
      icon: schoolIcon,
      zIndex: 2,
    ));

    setState(() {});
  }

  void getPolylines() async {
    polylineCordinates.clear();

    List<PolylineCordinates> returnLocationList = await directionController!.getDistanceBetweenCoordinates(apiKey);

    if (returnLocationList.isNotEmpty) {
      for (var point in returnLocationList) {
        polylineCordinates.add(LatLng(point.latitude!, point.longitude!));
      }
      distanceCalculate();
      setState(() {});
    }
  }

  dataLoad(String searchText) async {
    addressLat.value = "";
    addressLng.value = "";
    googleGeocodeList.value = (await directionController!.getGooglePlacesList(searchText));
  }

  dataLoadGoogleGeocode(String lat, String lng) async {
    addressLat.value = "";
    addressLng.value = "";
    googleGeocodeList.value = (await directionController!.getGoogleGeocodeList(lat, lng));
  }

  void setCustomMarkerIcon() async {
    await BitmapDescriptor.fromAssetImage(const ImageConfiguration(devicePixelRatio: 0.5, size: Size(45, 45)), 'assets/marker/school.png').then((onValue) {
      schoolIcon = onValue;
    });

    await BitmapDescriptor.fromAssetImage(const ImageConfiguration(devicePixelRatio: 0.5, size: Size(45, 45)), 'assets/marker/placeholder.png').then((onValue) {
      studentIcon = onValue;
    });
  }

  @override
  void dispose() {
    searchTextEditingControl.dispose();
    studentSearchTextEditingControl.dispose();

    addressTextEditingControl.dispose();
    districtTextEditingControl.dispose();
    cityTextEditingControl.dispose();
    addressLatTextEditingControl.dispose();
    addressLngTextEditingControl.dispose();
    // googleMapController.future.then((value) => value.dispose());

    // addressLatTextEditingControl2.dispose();
    // addressLongTextEditingControl2.dispose();

    // googleMapController.future.then((value) => value.dispose());

    super.dispose();
  }

  RxString addressLat = "".obs;
  RxString addressLng = "".obs;

  RxBool mapTypeSwitch = false.obs;

  Rx<GoogleGeocodeListModel> googleGeocodeListModel = GoogleGeocodeListModel().obs;

  setGoogleGeocodeListModelModelToController() {
    addressTextEditingControl.text = googleGeocodeListModel.value.formattedAddress ?? "";
    districtTextEditingControl.text = googleGeocodeListModel.value.district ?? "";
    cityTextEditingControl.text = googleGeocodeListModel.value.city ?? "";
    addressLatTextEditingControl.text = directionController!.markerPoint.value.latitude.toString();
    addressLngTextEditingControl.text = directionController!.markerPoint.value.longitude.toString();
    addressLat.value = googleGeocodeListModel.value.lat ?? "";
    addressLng.value = googleGeocodeListModel.value.lng ?? "";

    model!.value.address = googleGeocodeListModel.value.formattedAddress ?? "";
    model!.value.district = googleGeocodeListModel.value.district ?? "";
    model!.value.city = googleGeocodeListModel.value.city ?? "";
    model!.value.locationLat = googleGeocodeListModel.value.lat ?? "";
    model!.value.locationLng = googleGeocodeListModel.value.lng ?? "";
    model!.value.distance = double.parse(googleGeocodeListModel.value.distance ?? "0");
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth > 760 && constraints.maxHeight >= 500
            ? Scaffold(
                body: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0, top: 4),
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          decoration: const BoxDecoration(
                            color: Color(0xfffafcff),
                            boxShadow: [
                              BoxShadow(blurRadius: 8.0),
                              BoxShadow(color: Colors.white, offset: Offset(0, -16)),
                              BoxShadow(color: Colors.white, offset: Offset(0, 16)),
                              BoxShadow(color: Colors.white, offset: Offset(-16, -16)),
                              BoxShadow(color: Colors.white, offset: Offset(-16, 16)),
                            ],
                          ),
                          width: 350,
                          
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8.0,
                                      right: 8.0,
                                    ),
                                    child: Row(
                                      children: [
                                        InkWell(
                                            onTap: () {
                                              Get.back();
                                            },
                                            child: const Icon(
                                              Icons.arrow_back,
                                              color: Color(0xff403f40),
                                              size: 18,
                                            )),
                                        const SizedBox(width: 7),
                                        Expanded(child: searchWidget()),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                        Row(
                                          children: [
                                            InkWell(
                                                onTap: () {
                                                  searchTextEditingControl.clear();
                                                  dataLoad(searchTextEditingControl.text);
                                                },
                                                child: const Icon(
                                                  Icons.cancel,
                                                  color: Color(0xff403f40),
                                                  size: 18,
                                                )),
                                            const SizedBox(width: 5),
                                            InkWell(
                                                onTap: () {
                                                  dataLoad(searchTextEditingControl.text);
                                                },
                                                child: const Icon(
                                                  Icons.search,
                                                  color: Color(0xff403f40),
                                                  size: 18,
                                                )),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // OKUL ADI
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 70,
                                      child: XText(
                                        label: "Okul Adı",
                                        align: TextAlign.start,
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        maxLines: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 25,
                                        padding: const EdgeInsets.only(top: 2, right: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: AppColorDark.editBorderColor),
                                        ),
                                        child: TextFormFocus(
                                          maxLength: 10,
                                          maxLines: 1,
                                          onFocus: () {},
                                          value: schoolName ?? "",
                                          isReadOnly: true,
                                        ),

                                        //  TextFormOnlyWeb(
                                        //   height: 25,
                                        //   textEditingController: schoolNameTextEditingControl,
                                        //   onChanged: (value) {
                                        //     // dataStudent.value.studentName = value;
                                        //     // modele atılacak
                                        //   },
                                        //   maxLines: 1,
                                        //   style: const TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.w600),
                                        // ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                // ÖĞRENCİ ADI
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 70,
                                      child: XText(
                                        label: "Öğrenci Adı",
                                        align: TextAlign.start,
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        maxLines: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 25,
                                        padding: const EdgeInsets.only(top: 2, right: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: AppColorDark.editBorderColor),
                                        ),
                                        child: TextFormFocus(
                                          maxLength: 10,
                                          maxLines: 1,
                                          onFocus: () {},
                                          value: studentName ?? "",
                                          isReadOnly: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                // ADRES ADI
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 70,
                                      child: XText(
                                        label: "Adres Adı",
                                        align: TextAlign.start,
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        maxLines: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 25,

                                        padding: const EdgeInsets.only(
                                          top: 2,
                                        ),

                                        // decoration: BoxDecoration(
                                        //   color: Colors.white,
                                        //   borderRadius: BorderRadius.circular(4),
                                        //   border: Border.all(color: AppColorDark.editBorderColor),
                                        // ),
                                        child: TextFormOnlyWeb(
                                          height: 25,
                                          textEditingController: addressNameTextEditingControl,
                                          onChanged: (value) {
                                            // dataStudent.value.studentName = value;
                                            // modele atılacak
                                          },
                                          maxLines: 1,
                                          style: const TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                //  ADRES
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const XText(
                                      label: "Adres",
                                      align: TextAlign.center,
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: address(),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 5),
                                // İlçe
                                Row(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const XText(
                                          label: "İlçe",
                                          align: TextAlign.center,
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(width: 23),
                                        district(),
                                      ],
                                    ),
                                    const Spacer(),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const XText(
                                          label: "Şehir",
                                          align: TextAlign.center,
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(width: 10),
                                        city(),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                // KONUM
                                Row(
                                  children: [
                                    const XText(
                                      label: "Konum",
                                      align: TextAlign.center,
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(width: 5),
                                    Container(
                                      alignment: Alignment.center,
                                      height: 25,
                                      width: 120,
                                      padding: const EdgeInsets.only(top: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: AppColorDark.editBorderColor),
                                      ),
                                      child: Obx(
                                        () => XText(
                                          label: model!.value.locationLat == "40.994089"
                                              ? ""
                                              : model!.value.locationLat.toString(), //addressLat.value.toString().isEmpty ? widget.studentLat.toString() : addressLat.value.toString(),
                                          align: TextAlign.center,
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      alignment: Alignment.center,
                                      height: 25,
                                      width: 120,
                                      padding: const EdgeInsets.only(top: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: AppColorDark.editBorderColor),
                                      ),
                                      child: Obx(
                                        () => XText(
                                          label: model!.value.locationLng == "28.819928"
                                              ? ""
                                              : model!.value.locationLng.toString(), //addressLng.value.toString().isEmpty ? widget.studentLng.toString() : addressLng.value.toString(),
                                          align: TextAlign.center,
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                // MESAFE
                                Row(
                                  children: [
                                    const XText(
                                      label: "Mesafe",
                                      align: TextAlign.center,
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(width: 7),
                                    Container(
                                        alignment: Alignment.center,
                                        height: 25,
                                        width: 120,
                                        padding: const EdgeInsets.only(top: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: AppColorDark.editBorderColor),
                                        ),
                                        child: Obx(
                                          () => TextFormFocus(
                                            maxLength: 10,
                                            maxLines: 1,
                                            onFocus: () {},
                                            value: model!.value.distance.toString(),
                                            onChanged: (value) {
                                              // model!.value.distance = double.parse(value);
                                            },
                                            isReadOnly: true,
                                          ),
                                        )),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  color: Colors.white,
                                  width: 300,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Obx(() => IgnorePointer(
                                                ignoring: !isDrawRoute.value,
                                                child: MenuButtonColor(
                                                  caption: "Rota Oluştur",
                                                  icon: const Icon(Icons.double_arrow, size: 16, color: Color(0xFFffffff)),
                                                  radius: 4,
                                                  width: 100,
                                                  height: 30,
                                                  color: const Color(0xFF142828),
                                                  colorBorder: const Color(0xFF142828),
                                                  colorHover: const Color(0xFF142828),
                                                  colorHoverBorder: const Color(0xFF142828),
                                                  colorText: const Color(0xFFffffff),
                                                  onButtonClicked: () async {
                                                    if (model!.value.locationLat!.isNotEmpty && model!.value.locationLng!.isNotEmpty) {
                                                      if (directionController!.markerPoint.value.latitude == 40.994089 && directionController!.markerPoint.value.longitude == 28.819928 ||
                                                          directionController!.schoolLocationLatLng.value.latitude != null ||
                                                          directionController!.schoolLocationLatLng.value.latitude != null ||
                                                          directionController!.schoolLocationLatLng.value.latitude != 0.0 ||
                                                          directionController!.schoolLocationLatLng.value.longitude != 0.0) {
                                                        getPolylines();
                                                        isDrawRoute.value = false;
                                                      }
                                                      if (directionController!.markerPoint.value.latitude == 40.994089 && directionController!.markerPoint.value.longitude == 28.819928) {
                                                        Get.snackbar("Hata", "Lütfen öğrencinin konumunu seçiniz.",
                                                            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
                                                      }
                                                      if (directionController!.schoolLocationLatLng.value.latitude == null ||
                                                          directionController!.schoolLocationLatLng.value.longitude == null ||
                                                          directionController!.schoolLocationLatLng.value.latitude == 0.0 ||
                                                          directionController!.schoolLocationLatLng.value.longitude == 0.0) {
                                                        Get.snackbar("Hata", "Okulun konum bilgileri bulunamadı. Lütfen okulun konumunu okul bilgileri sayfasından giriniz.",
                                                            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
                                                      }
                                                    } else {
                                                      // Get.snackbar("Hata", "Lütfen öğrencinin konumunu seçiniz.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
                                                    }
                                                  },
                                                ),
                                              )),
                                          const SizedBox(width: 5),
                                          MenuButtonColor(
                                            caption: "Kaydet",
                                            icon: const Icon(Icons.double_arrow, size: 16, color: Color(0xFFffffff)),
                                            radius: 4,
                                            width: 90,
                                            height: 30,
                                            color: const Color(0xFF142828),
                                            colorBorder: const Color(0xFF142828),
                                            colorHover: const Color(0xFF142828),
                                            colorHoverBorder: const Color(0xFF142828),
                                            colorText: const Color(0xFFffffff),
                                            onButtonClicked: () async {
                                              MessageModel r = await studentServicePlanningController!.setStudentAdress(model!.value);
                                              if (r.messageID! > 0) {
                                                studentServicePlanningController!.setStudentUpdateAdressList(model!.value);
                                              }

                                              // GoogleGeocodeListModel x = GoogleGeocodeListModel(
                                              //   country: "",
                                              //   formattedAddress: addressTextEditingControl.text,
                                              //   city: cityTextEditingControl.text,
                                              //   district: districtTextEditingControl.text,
                                              //   lat: directionController!.markerPoint.value.latitude.toString(), //addressLatTextEditingControl.text,
                                              //   lng: directionController!.markerPoint.value.longitude.toString(), //addressLatTextEditingControl.text,
                                              //   distance: directionController!.distanceBetweenCoordinates.value.toString().replaceAll(" km", ""),
                                              // );
                                              // // widget.onBack!(x);
                                              // Get.back();
                                            },
                                          ),
                                          const SizedBox(width: 5),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Expanded(child: addressList()),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: MenuButtonColor(
                                          caption: "Kapat",
                                          icon: const Icon(Icons.double_arrow, size: 16, color: Color(0xFFffffff)),
                                          radius: 4,
                                          width: 90,
                                          height: 30,
                                          color: const Color(0xFF142828),
                                          colorBorder: const Color(0xFF142828),
                                          colorHover: const Color(0xFF142828),
                                          colorHoverBorder: const Color(0xFF142828),
                                          colorText: const Color(0xFFffffff),
                                          onButtonClicked: () {
                                            Get.back();
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height,
                              child: Obx(
                                () => GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: model!.value.locationLat!.isNotEmpty || model!.value.locationLng!.isNotEmpty
                                          ? LatLng(double.parse(model!.value.locationLat!), double.parse(model!.value.locationLng!))
                                          : const LatLng(41.01749245824437, 28.814337869481204),
                                      zoom: 16,
                                    ),
                                    onMapCreated: (GoogleMapController controller) async {
                                      googleMapController.complete(controller);
                                      await controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: directionController!.markerPoint.value, zoom: 17)));
                                    },
                                    onTap: (latLng) {
                                      isDrawRoute.value = true;

                                      googleMapController.future.then((value) {
                                        CameraUpdate.newCameraPosition(CameraPosition(target: latLng, zoom: 17));
                                      });
                                      setState(() {});

                                      setLatLongPoint(latLng);
                                      directionController!.setStudentLocation(latLng.latitude, latLng.longitude);
                                      polylineCordinates.clear();
                                      directionController!.markersRx.removeWhere((p0) => p0.zIndex == 1.0);
                                      directionController!.setMarkerRx(Marker(
                                        markerId: MarkerId(latLng.latitude.toString()),
                                        position: latLng,
                                        infoWindow: const InfoWindow(
                                          title: "Konum",
                                          snippet: "Konumunuz",
                                        ),
                                        zIndex: 1,
                                        draggable: true,
                                        onDrag: (value) {
                                          setLatLongPoint(value);
                                        },
                                        icon: studentIcon,
                                      ));
                                    },
                                    polylines: {
                                      Polyline(
                                        polylineId: const PolylineId('1'),
                                        points: polylineCordinates,
                                        color: Colors.blueGrey,
                                        width: 5,
                                      ),
                                    },
                                    markers: directionController!.markersRx,
                                    myLocationEnabled: false,
                                    myLocationButtonEnabled: false,
                                    mapType: mapTypeSwitch.value ? MapType.satellite : MapType.normal),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 5,
                              child: Obx(
                                () => Material(
                                  elevation: 4,
                                  color: mapTypeSwitch.value ? Colors.white : const Color(0xff403f40),
                                  borderRadius: BorderRadius.circular(4),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: SizedBox(
                                      child: Column(
                                        children: [
                                          Text(
                                            "Harita Tipi",
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: mapTypeSwitch.value ? const Color(0xff403f40) : Colors.white),
                                          ),
                                          CupertinoSwitch(
                                            value: mapTypeSwitch.value,
                                            onChanged: (data) {
                                              mapTypeSwitch.value = data;
                                            },
                                            thumbColor: mapTypeSwitch.value ? Colors.white : const Color(0xff403f40),
                                            activeColor: const Color(0xff403f40),
                                            trackColor: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      studentList()
                    ],
                  ),
                ),
              )
            : Container());
  }

  void distanceCalculate() {
    String distanceText = directionController!.distanceBetweenCoordinates.value;
    double? distanceValue = double.tryParse(distanceText.split(' ')[0]);
    if (distanceValue != null) {
      model!.value.distance = distanceValue;
    } else {
      model!.value.distance = 0.0;
    }
    model!.refresh();
  }

  // void setLatLongPoint(LatLng latLng) {
  //   if (widget.address.isNotEmpty) {
  //     addressLat.value = latLng.latitude.toString();
  //     addressLng.value = latLng.longitude.toString();
  //     directionController!.setMarkerPoint(latLng.latitude, latLng.longitude);
  //     dataLoadGoogleGeocode(latLng.latitude.toString(), latLng.longitude.toString());
  //   } else {
  //     addressLat.value = latLng.latitude.toString();
  //     addressLng.value = latLng.longitude.toString();
  //     directionController!.setMarkerPoint(latLng.latitude, latLng.longitude);
  //     dataLoadGoogleGeocode(latLng.latitude.toString(), latLng.longitude.toString());
  //   }
  // }

  void scrollToIndex() {
    int index = studentServicePlanningController!.newServiceWeekStudentListSelected.indexWhere((student) => student.studentAddressID == selectedStudentAddressID.value);

    if (index != -1) {
      itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  int selectedOption = 0;
  studentList() {
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: Row(
            children: <Widget>[
              Radio<int>(
                // <int> eklenerek tip belirtildi
                value: 0,
                groupValue: selectedOption,
                onChanged: (int? value) {
                  studentServicePlanningController!.adressSelectedListAdd();

                  studentServicePlanningController!.newServiceWeekStudentListSelected.refresh;

                  setState(() {
                    selectedOption = value!;
                  });
                },
              ),
              Text('Tüm öğrenciler'),
              Radio<int>(
                // <int> eklenerek tip belirtildi
                value: 1,
                groupValue: selectedOption,
                onChanged: (int? value) {
                  List<ServiceWeekStudentListV2Model> filteredList = studentServicePlanningController!.newServiceWeekStudentListSelected.where((student) => student.locationLat == "").toList();

                  studentServicePlanningController!.newServiceWeekStudentListSelected.value = filteredList;
                  // int? olarak değiştirildi
                  setState(() {
                    selectedOption = value!;
                  });
                },
              ),
              Text('Konumu Olmayan Öğrenciler'),
            ],
          ),
        ),
        studentSearchWidget(),
        Expanded(
          child: Container(
            width: 350,
            color: Colors.transparent,
            child: Obx(() => ScrollablePositionedList.builder(
                  itemScrollController: itemScrollController,
                  itemPositionsListener: itemPositionsListener,
                  shrinkWrap: true,
                  itemCount: studentServicePlanningController!.newServiceWeekStudentListSelected.length,
                  itemBuilder: (context, indexStudent) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4, top: 4),
                      child: Container(
                        alignment: Alignment.topLeft,
                        width: 250,
                        height: 120,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(color: const Color(0xff3e66ff).withOpacity(0.3), offset: const Offset(-1, 1), blurRadius: 3.0, spreadRadius: 1.0),
                          ],
                          // color: Colors.white,
                          color: selectedStudentAddressID.value == studentServicePlanningController!.newServiceWeekStudentListSelected[indexStudent].studentAddressID
                              ? Color.fromARGB(255, 192, 214, 255)
                              : Colors.white,

                          borderRadius: BorderRadius.circular(5),
                          //  color: Color(0xffe1edff),
                          //border:   Border.all(color: Colors.grey.withOpacity(0.3))
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              textColor: selectedStudentAddressID.value == studentServicePlanningController!.newServiceWeekStudentListSelected[indexStudent].studentAddressID
                                  ? const Color.fromARGB(255, 0, 85, 255)
                                  : studentServicePlanningController!.newServiceWeekStudentListSelected[indexStudent].locationLat!.isEmpty
                                      ? Colors.red
                                      : Colors.black,
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  XTextPoppins(
                                      label: studentServicePlanningController!.newServiceWeekStudentListSelected[indexStudent].studentName!,
                                      align: TextAlign.start,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: studentServicePlanningController!.newServiceWeekStudentListSelected[indexStudent].locationLat!.isEmpty ? Colors.red : Colors.black,
                                      maxLines: 1),
                                  XTextPoppins(
                                      label: studentServicePlanningController!.newServiceWeekStudentListSelected[indexStudent].addressName!,
                                      align: TextAlign.start,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: studentServicePlanningController!.newServiceWeekStudentListSelected[indexStudent].locationLat!.isEmpty ? Colors.red : Colors.black,
                                      maxLines: 1),
                                  XTextPoppins(
                                      label: studentServicePlanningController!.newServiceWeekStudentListSelected[indexStudent].address!,
                                      align: TextAlign.start,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: studentServicePlanningController!.newServiceWeekStudentListSelected[indexStudent].locationLat!.isEmpty ? Colors.red : Colors.black,
                                      maxLines: 1),
                                  XTextPoppins(
                                      label: studentServicePlanningController!.newServiceWeekStudentListSelected[indexStudent].serviceName ?? '',
                                      align: TextAlign.start,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: studentServicePlanningController!.newServiceWeekStudentListSelected[indexStudent].locationLat!.isEmpty ? Colors.red : Colors.black,
                                      maxLines: 1),
                                  XTextPoppins(
                                    label: studentServicePlanningController!.newServiceWeekStudentListSelected[indexStudent].schoolName!,
                                    align: TextAlign.start,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    maxLines: 1,
                                    color: studentServicePlanningController!.newServiceWeekStudentListSelected[indexStudent].locationLat!.isEmpty ? Colors.red : Colors.black,
                                  ),
                                ],
                              ),
                              selectedColor: studentServicePlanningController!.newServiceWeekStudentListSelected[indexStudent].locationLat!.isEmpty ? Colors.red : Colors.black,
                              selected: selectedStudentAddressID.value == studentServicePlanningController!.newServiceWeekStudentListSelected[indexStudent].studentAddressID ? true : false,
                              onTap: () async {
                                isDrawRoute.value = true;

                                selectindex = 0;
                                schoolDataLoad(studentServicePlanningController!.newServiceWeekStudentListSelected[indexStudent].schoolID.toString());
                                selectedStudentAddressID.value = studentServicePlanningController!.newServiceWeekStudentListSelected[indexStudent].studentAddressID!;
                                setState(() {});
                                ServiceWeekStudentListV2Model x = studentServicePlanningController!.newServiceWeekStudentListSelected[indexStudent];
                                model!.value = StudentAddressModel(
                                  studentAddressID: x.studentAddressID,
                                  studentID: x.studentID,
                                  addressName: x.addressName,
                                  city: x.city,
                                  district: x.district,
                                  address: x.address,
                                  locationLat: x.locationLat,
                                  locationLng: x.locationLng,
                                  distance: x.distance == null ? 0 : x.distance!.toDouble(),
                                  isPassive: false,
                                  defaultAddress: true,
                                  recordUser: "",
                                  schoolMeter: x.distance == null ? 0 : x.distance!.toDouble(),
                                  price: 0.0,
                                );
                                setModelToController();

                                if (model!.value.locationLat!.isNotEmpty && model!.value.locationLng!.isNotEmpty) {
                                  setStudentLocationMarker();
                                } else {
                                  polylineCordinates.clear();

                                  directionController!.markersRx.removeWhere((element) => element.zIndex == 1.0);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
          ),
        ),
      ],
    );
  }

  void setStudentLocationMarker() {
    double lat = double.parse(model!.value.locationLat!);
    double lng = double.parse(model!.value.locationLng!);
    directionController!.setStudentLocation(lat, lng);
    googleMapController.future.then((value) {
      value.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat, lng), zoom: 17.0)));
    });
    polylineCordinates.clear();

    directionController!.markersRx.removeWhere((element) => element.zIndex == 1.0);
    directionController!.setMarkerRx(Marker(
      markerId: MarkerId(lat.toString()),
      position: LatLng(lat, lng),
      infoWindow: const InfoWindow(
        title: "Konum",
        snippet: "Konumunuz",
      ),
      zIndex: 1,
      draggable: true,
      onDrag: (value) {
        debugPrint("onDrag, $value");
        setLatLongPoint(value);
      },
      icon: studentIcon,
    ));
    addressLat.value = lat.toString();
    addressLng.value = lng.toString();
    setLatLongPoint(LatLng(lat, lng));
    // directionController!.setMarkerPoint(lat, lng);
  }

  SizedBox address() {
    return SizedBox(
      height: 50,
      child: TextFormOnlyWeb(
        height: 25,
        textEditingController: addressTextEditingControl,
        onChanged: (value) {
          // dataStudent.value.studentName = value;
          // modele atılacak
        },
        maxLines: 3,
        style: const TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.w600),
      ),
    );
  }

  SizedBox district() {
    return SizedBox(
      height: 25,
      width: 120,
      child: TextFormOnlyWeb(
          height: 25,
          textEditingController: districtTextEditingControl,
          onChanged: (value) {
            // dataStudent.value.studentName = value;
            // modele atılacak
          },
          maxLines: 1,
          style: const TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.w600)),
    );
  }

  SizedBox city() {
    return SizedBox(
      width: 120,
      height: 25,
      child: TextFormOnlyWeb(
        height: 25,
        textEditingController: cityTextEditingControl,
        onChanged: (value) {
          // dataStudent.value.studentName = value;
          // modele atılacak
        },
        maxLines: 1,
        style: const TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget searchWidget() {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: TextFormField(
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 15),
        scrollPadding: const EdgeInsets.all(0),
        controller: searchTextEditingControl,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xfff7f8fd),
          contentPadding: const EdgeInsets.only(left: 12, right: 12, top: 0, bottom: 0),
          hintText: "Haritada Ara",
          hintStyle: GoogleFonts.inter(color: Colors.black.withOpacity(0.8), fontWeight: FontWeight.w400, fontSize: 15),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          alignLabelWithHint: true,
        ),
        // onChanged: (value) {
        //  placesList =   getPlaces();
        //   //  debugPrint(placesList.toString());
        //   dataLoad(value, "0.0", "0.0");
        // },
      ),
    );
  }

  Widget studentSearchWidget() {
    return SizedBox(
      height: 40,
      width: 300,
      child: TextFormField(
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 15),
        scrollPadding: const EdgeInsets.all(0),
        controller: studentSearchTextEditingControl,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xfff7f8fd),
          contentPadding: const EdgeInsets.only(left: 12, right: 12, top: 0, bottom: 0),
          hintText: "Öğrenci Ara",
          hintStyle: GoogleFonts.inter(color: Colors.black.withOpacity(0.8), fontWeight: FontWeight.w400, fontSize: 15),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: Colors.deepPurple, width: 2)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide(color: Colors.grey.withOpacity(0.5))),
          alignLabelWithHint: true,
        ),
        onChanged: (value) {
          filterList(value);
        },
      ),
    );
  }

  int selectindex = 0;

  Widget addressList() {
    return Obx(
      () => ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return StreamBuilder<Object>(
              stream: null,
              builder: (context, snapshot) {
                return InkWell(
                  onHover: (value) {
                    // setState(() {
                    //   selectindex = index;
                    // });
                  },
                  onTap: () async {
                    isDrawRoute.value = true;

                    if (model!.value.address!.isNotEmpty) {
                      double lat = double.parse(googleGeocodeList[index].lat?.replaceAll(",", ".") ?? "0.0");
                      double lng = double.parse(googleGeocodeList[index].lng?.replaceAll(",", ".") ?? "0.0");
                      directionController!.setStudentLocation(lat, lng);

                      googleMapController.future.then((value) {
                        value.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat, lng), zoom: 17.0)));
                      });
                      polylineCordinates.clear();

                      directionController!.markersRx.removeWhere((element) => element.zIndex == 1.0);
                      directionController!.setMarkerRx(Marker(
                        markerId: MarkerId(lat.toString()),
                        position: LatLng(lat, lng),
                        infoWindow: const InfoWindow(
                          title: "Konum",
                          snippet: "Konumunuz",
                        ),
                        zIndex: 1,
                        draggable: true,
                        onDrag: (value) {
                          debugPrint("onDrag, $value");
                          setLatLongPoint(value);
                        },
                        icon: studentIcon,
                      ));
                      addressLat.value = lat.toString();
                      addressLng.value = lng.toString();
                      directionController!.setMarkerPoint(lat, lng);

                      googleGeocodeListModel.value.formattedAddress = googleGeocodeList[index].formattedAddress;
                      googleGeocodeListModel.value.lat = googleGeocodeList[index].lat?.replaceAll(",", ".") ?? "0.0";
                      googleGeocodeListModel.value.lng = googleGeocodeList[index].lng?.replaceAll(",", ".") ?? "0.0";
                      googleGeocodeListModel.value.city = googleGeocodeList[index].city;
                      googleGeocodeListModel.value.district = googleGeocodeList[index].district;
                      googleGeocodeListModel.value.country = googleGeocodeList[index].country;

                      setGoogleGeocodeListModelModelToController();
                    } else {
                      googleGeocodeListModel.value.formattedAddress = googleGeocodeList[index].formattedAddress;
                      googleGeocodeListModel.value.lat = googleGeocodeList[index].lat?.replaceAll(",", ".") ?? "0.0";
                      googleGeocodeListModel.value.lng = googleGeocodeList[index].lng?.replaceAll(",", ".") ?? "0.0";
                      googleGeocodeListModel.value.city = googleGeocodeList[index].city;
                      googleGeocodeListModel.value.district = googleGeocodeList[index].district;
                      googleGeocodeListModel.value.country = googleGeocodeList[index].country;

                      setGoogleGeocodeListModelModelToController();

                      double lat = double.parse(googleGeocodeListModel.value.lat!);
                      double lng = double.parse(googleGeocodeListModel.value.lng!);
                      directionController!.setStudentLocation(lat, lng);
                      googleMapController.future.then((value) {
                        value.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat, lng), zoom: 17.0)));
                      });
                      polylineCordinates.clear();

                      directionController!.markersRx.removeWhere((element) => element.zIndex == 1.0);
                      directionController!.setMarkerRx(Marker(
                        markerId: MarkerId(lat.toString()),
                        position: LatLng(lat, lng),
                        infoWindow: const InfoWindow(
                          title: "Konum",
                          snippet: "Konumunuz",
                        ),
                        zIndex: 1,
                        draggable: true,
                        onDrag: (value) {
                          debugPrint("onDrag, $value");
                          setLatLongPoint(value);
                        },
                        icon: studentIcon,
                      ));
                      addressLat.value = lat.toString();
                      addressLng.value = lng.toString();
                      directionController!.setMarkerPoint(lat, lng);
                    }
                    setState(() {
                      selectindex = index;
                    });
                  },
                  onDoubleTap: () async {
                    googleGeocodeListModel.value.formattedAddress = googleGeocodeList[index].formattedAddress;
                    googleGeocodeListModel.value.lat = googleGeocodeList[index].lat?.replaceAll(",", ".") ?? "0.0";
                    googleGeocodeListModel.value.lng = googleGeocodeList[index].lng?.replaceAll(",", ".") ?? "0.0";
                    googleGeocodeListModel.value.city = googleGeocodeList[index].city;
                    googleGeocodeListModel.value.district = googleGeocodeList[index].district;
                    googleGeocodeListModel.value.country = googleGeocodeList[index].country;

                    setGoogleGeocodeListModelModelToController();

                    double lat = double.parse(googleGeocodeListModel.value.lat!);
                    double lng = double.parse(googleGeocodeListModel.value.lng!);
                    directionController!.setStudentLocation(lat, lng);

                    googleMapController.future.then((value) {
                      value.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat, lng), zoom: 17.0)));
                    });

                    polylineCordinates.clear();

                    directionController!.markersRx.removeWhere((element) => element.zIndex == 1.0);
                    directionController!.setMarkerRx(Marker(
                      markerId: MarkerId(lat.toString()),
                      position: LatLng(lat, lng),
                      infoWindow: const InfoWindow(
                        title: "Konum",
                        snippet: "Konumunuz",
                      ),
                      draggable: true,
                      onDrag: (value) {
                        debugPrint("onDrag, $value");
                        setLatLongPoint(value);
                      },
                      zIndex: 1,
                      icon: studentIcon,
                    ));

                    addressLat.value = lat.toString();
                    addressLng.value = lng.toString();

                    directionController!.setMarkerPoint(lat, lng);
                  },
                  child: Container(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      height: 120.0,
                      margin: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          selectindex == index
                              ? BoxShadow(
                                  color: Colors.grey.shade400,
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(3, 3), // changes position of shadow
                                )
                              : const BoxShadow()
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 5,
                            height: 100,
                            decoration: BoxDecoration(
                              color: selectindex == index ? const Color(0xff403f40) : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(googleGeocodeList[index].formattedAddress!, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Color(0xff36466c))),
                                const SizedBox(height: 5.0),
                                Text('${googleGeocodeList[index].lat?.replaceAll(",", ".") ?? "0.0"} ${googleGeocodeList[index].lng?.replaceAll(",", ".") ?? "0.0"}',
                                    style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: Color(0xff8d9abd))),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          Container(
                            width: 5,
                            height: 100,
                            decoration: BoxDecoration(
                              color: selectindex == index ? const Color(0xff403f40) : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      )),
                  // child: ListTile(
                  //   title: Text(googleGeocodeList[index].formattedAddress!),
                  //   subtitle: Text('${googleGeocodeList[index].lat?.replaceAll(",", ".") ?? "0.0"} ${googleGeocodeList[index].lng?.replaceAll(",", ".") ?? "0.0"}'),
                  // ),
                );
              });
        },
        itemCount: googleGeocodeList.length,
      ),
    );
  }
}
