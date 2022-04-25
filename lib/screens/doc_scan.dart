import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as Path;
import 'dart:async';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:pdf/pdf.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:photofilters/filters/filters.dart';
import 'package:photofilters/filters/preset_filters.dart';
import 'package:photofilters/widgets/photo_filter.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:edge_detection/edge_detection.dart';

import 'first_screen.dart';
class Doc_Scanner extends StatefulWidget {
  Doc_Scanner({required this.filespath});
  final String filespath;
  @override
  _Doc_Scanner createState() => _Doc_Scanner();
}

class _Doc_Scanner extends State<Doc_Scanner> {
  final picker = ImagePicker();
  final pdf = PdfDocument();
  late var spt="";
  late var ps="";
  late var prev=0;
  late var p=0;
  List<File> _image = [];
  late TextEditingController _controller=TextEditingController();
  late TextEditingController _controller2=TextEditingController();
  late String fileName;
  List<Filter> filters = presetFiltersList;
  late File imageFile;
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.black;
      }
      return Colors.black;
    }
    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: AppBar(
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0.0,
        toolbarHeight: 60,
        title: const Padding(
          padding: EdgeInsets.only(left: 0.0 , bottom: 0),
          child: Text("Doc Scanner" ,style: TextStyle(color: Colors.black , fontWeight: FontWeight.w700 , fontSize: 22),),
        ) , backgroundColor: const Color(0xfff8f5f0) ,iconTheme: const IconThemeData(color: Colors.black) ,elevation: 0.0,
        actions: [
          IconButton(
              icon: const Icon(CupertinoIcons.square_arrow_down_on_square , size: 25, color: Colors.black,),
              onPressed: () async {
                createPDF();
                savePDF();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => FirstScreen()));
                p++;
              }),
          IconButton(
              icon: const Icon(CupertinoIcons.pencil_circle , size: 25 , color: Colors.black),
              onPressed: () async {
                final sp = await opendialogue();
                if(sp!=Null){
                  setState(() {
                    this.spt=sp as String ;
                    p++;
                  });
                }
              }),
          Checkbox(
            checkColor: Colors.white,
            fillColor: MaterialStateProperty.resolveWith(getColor),
            value: isChecked,
            onChanged: (bool? value) {
              setState(() {
                isChecked = value!;
              });
            },
          ),
        ],
      ),
        floatingActionButton: Stack(
          children: <Widget>[
            Padding(padding: const EdgeInsets.only(left:31, bottom: 50),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton(
                  onPressed: getImageFromCamera,
                  backgroundColor: Colors.pink,
                  autofocus: true,
                  elevation: 0.0,
                  child: const Icon(CupertinoIcons.camera_viewfinder,  size: 40,color: Colors.white,),),
              ),),
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed:() async {
                      final ps = await opendialogue2();
                      if(ps!=Null){
                        setState(() {
                        this.ps=ps as String ;
                        createPDF();
                        p++;
                        });
                      }
                  },
                backgroundColor: Colors.red,
                autofocus: true,
                elevation: 0.0,
                child: const Icon(Icons.security , size: 30,color: Colors.white,),),
            ),
          ],
        ),