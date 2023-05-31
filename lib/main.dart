import 'package:excel_deneme/model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: MyHomePage()

          // containerWidgets(), // BelediyeList()
          ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<BelediyeModel> dataList = [
    BelediyeModel(
      title: "Belediye Başlığı 1",
      icon: Icons.home,
      content1: "İçerik 1",
      content2: "İçerik 2",
      content3: "İçerik 3",
    ),
    BelediyeModel(
      title: "Belediye Başlığı 2",
      icon: Icons.business,
      content1: "İçerik 4",
      content2: "İçerik 5",
      content3: "İçerik 6",
    ),
    BelediyeModel(
      title: "Belediye Başlığı 3",
      icon: Icons.school,
      content1: "İçerik 7",
      content2: "İçerik 8",
      content3: "İçerik 9",
    ),
  ];

  int selectedIndex = 0;
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Cep Başkan',
            style: GoogleFonts.caveat(fontSize: 40, fontStyle: FontStyle.italic),
          ),
          backgroundColor: const Color(0xff00406c)),
      body: Container(
        decoration: const BoxDecoration(
            // image: DecorationImage(
            //     image: AssetImage("images/new.jpeg"), fit: BoxFit.fill)
            ),
        child: ListView.builder(
          itemCount: dataList.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ExpandedCard(
                data: dataList[index],
                  onTap: () {
                    selectedIndex = index;
                    setState(() {});
                  },
                  isSelected: selectedIndex == index ? true : false),
            );
          },
        ),
      ),
    );
  }
}

// class expandedCard extends StatefulWidget {
//   // final IconData icondata;
//   final bool isSelected;
//   final Function onTap;
//   const expandedCard({
//     super.key,
//     required this.isSelected,
//     required this.onTap, // required this.icondata,
//   });

//   @override
//   State<expandedCard> createState() => _expandedCardState();
// }

// class _expandedCardState extends State<expandedCard> {
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         widget.onTap();
//         // setState(() {
//         //   selected = !selected;
//         // });
//       },
//       child: Center(
//         child: AnimatedContainer(
//           width: widget.isSelected ? 850.0 : 850.0,
//           height: widget.isSelected ? 122.0 : 105.0,
//           color: widget.isSelected
//               ? Colors.grey.withOpacity(0.5)
//               : Colors.grey.withOpacity(0.2),
//           alignment: widget.isSelected
//               ? Alignment.topCenter
//               : AlignmentDirectional.topStart,
//           duration: const Duration(seconds: 2),
//           curve: Curves.fastOutSlowIn,
//           child: Visibility(
//             visible: widget.isSelected,
//             maintainAnimation: true,
//             maintainSize: true,
//             maintainState: true,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     const Padding(
//                       padding: EdgeInsets.only(
//                         top: 3,
//                         bottom: 4,
//                         left: 3,
//                       ),
//                       child: Icon(
//                         Icons.movie_edit,
//                         color: Colors.white,
//                         size: 35,
//                       ),
//                     ),
//                     Text(
//                       "Randevular",
//                       style: GoogleFonts.permanentMarker(
//                           fontSize: 25,
//                           fontStyle: FontStyle.normal,
//                           color: Colors.white),
//                     ),
//                   ],
//                 ),

//                 //***burayı ben yazdım görmek için*******
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.arrow_right,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                         Text(
//                           "Onaysız Randevular",
//                           style: GoogleFonts.itim(
//                               fontSize: 14,
//                               fontStyle: FontStyle.normal,
//                               color: Colors.white.withOpacity(0.8)),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.arrow_right,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                         Text(
//                           "Kesinleşmiş Randevular",
//                           style: GoogleFonts.itim(
//                               fontSize: 14,
//                               fontStyle: FontStyle.normal,
//                               color: Colors.white.withOpacity(0.8)),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.arrow_right,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                         Text(
//                           "Reddedilen Randevular",
//                           style: GoogleFonts.itim(
//                               fontSize: 14,
//                               fontStyle: FontStyle.normal,
//                               color: Colors.white.withOpacity(0.8)),
//                         ),
//                       ],
//                     ),
//                     // Row(
//                     //   children: [
//                     //     Icon(
//                     //       Icons.arrow_right,
//                     //       color: Colors.white,
//                     //       size: 20,
//                     //     ),
//                     //     Text("data"),
//                     //   ],
//                     // ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class ExpandedCard extends StatefulWidget {
  final BelediyeModel data;
  final bool isSelected;
  final Function onTap;

  const ExpandedCard({
    Key? key,
    required this.isSelected,
    required this.onTap, required this.data,
  }) : super(key: key);

  @override
  _ExpandedCardState createState() => _ExpandedCardState();
}

class _ExpandedCardState extends State<ExpandedCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Center(
        child: AnimatedContainer(
          width: widget.isSelected ? 850.0 : 850.0,
          height: isExpanded ? 122.0 : 50.0,
          color: widget.isSelected ? Colors.grey.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
          alignment: widget.isSelected ? Alignment.topCenter : AlignmentDirectional.topStart,
          duration: const Duration(seconds: 2),
          curve: Curves.fastOutSlowIn,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                     Padding(
                      padding: const EdgeInsets.only(
                        top: 3,
                        bottom: 4,
                        left: 3,
                      ),
                      child: Icon(
                        widget.data.icon!,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                    Text(
                      widget.data.title!,
                      style: GoogleFonts.permanentMarker(
                        fontSize: 25,
                        fontStyle: FontStyle.normal,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.arrow_right,
                            color: Colors.white,
                            size: 20,
                          ),
                          Text(
                            widget.data.content1!,
                            style: GoogleFonts.itim(
                              fontSize: 14,
                              fontStyle: FontStyle.normal,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.arrow_right,
                            color: Colors.white,
                            size: 20,
                          ),
                          Text(
                            widget.data.content2!,
                            style: GoogleFonts.itim(
                              fontSize: 14,
                              fontStyle: FontStyle.normal,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.arrow_right,
                            color: Colors.white,
                            size: 20,
                          ),
                          Text(
                            widget.data.content3!,
                            style: GoogleFonts.itim(
                              fontSize: 14,
                              fontStyle: FontStyle.normal,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
