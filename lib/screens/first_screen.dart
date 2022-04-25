import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdftoolapplicario/screens/doc_scan.dart';
import 'package:pdftoolapplicario/screens/imagetopdf.dart';
import 'package:pdftoolapplicario/screens/pdf_merge.dart';
import 'package:pdftoolapplicario/ui_view/slider_layout_view.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_merger/pdf_merger.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:smart_select/smart_select.dart';
import 'package:share/share.dart';

import 'inner_screen.dart';
class FirstScreen extends StatefulWidget{

  @override
  State<StatefulWidget> createState() => _FirstScreen();
}
class _FirstScreen extends State<FirstScreen>{
  late SearchBar searchBar;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController controller = TextEditingController();
  var files;
  String _search="";
  void getFiles() async { //asyn function to get list of files
    final dir = await getExternalStorageDirectory();
    var fm = FileManager(root: dir); //
    files = await fm.filesTree(
        excludedPaths: ["/storage/emulated/0/Android"],
        extensions: ["pdf"], //optional, to filter files, list only pdf files
    );
    setState(() {}); //update the UI
  }
  Future<String> createFolderInAppDocDir(String folderName) async {
    final Directory? _appDocDir = await getExternalStorageDirectory();
    //App Document Directory + folder name
    final Directory _appDocDirFolder =
    Directory('${_appDocDir?.path}/$folderName/');

    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder =
      await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }

  callFolderCreationMethod(String folderInAppDocDir) async {
    // ignore: unused_local_variable
    String actualFileName = await createFolderInAppDocDir(folderInAppDocDir);
    print(actualFileName);
    setState(() {});
  }

  final folderController = TextEditingController();
  String nameOfFolder="";
  Future<void> _showMyDialog() async => showDialog<void>(
      context: context,// user must tap button!
      builder: (BuildContext context) => AlertDialog(
          title: Column(
            children: const [
              Text(
                'ADD FOLDER',
                textAlign: TextAlign.left,
              ),
              Text(
                'Type a folder name to add',
                style: TextStyle(
                  fontSize: 14,
                ),
              )
            ],
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return TextField(
                controller: folderController,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Enter folder name'),
                onChanged: (val) {
                  setState(() {
                    nameOfFolder = folderController.text;
                    nameOfFolder+="-dc";
                    print(nameOfFolder);
                  });
                },
              );
            },
          ),
          actions: <Widget>[
            FlatButton(
              color: Colors.blue,
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                if (nameOfFolder != "") {
                  await callFolderCreationMethod(nameOfFolder);
                  getDir();
                  setState(() {
                    folderController.clear();
                    nameOfFolder = "";
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
            FlatButton(
              color: Colors.redAccent,
              child: const Text(
                'No',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
    );
List<FileSystemEntity> _folders=[];
  Future<void> getDir() async {
    final directory = await getExternalStorageDirectory();
    final dir = directory?.path;
    String pdfDirectory = '$dir/';
    final myDir = Directory(pdfDirectory);
    setState(() {
      _folders = myDir.listSync(recursive: true, followLinks: false);
    });
    _folders.removeWhere((path) => path.toString().contains("-dc")==false);
    _folders.removeWhere((path) => path.toString().split('/').last.contains(".pdf")==true);
    print(_folders);
  }
  Future<void> _showDeleteDialog(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      //555656
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Are you sure to delete this folder?',
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('Yes'),
              onPressed: () async {
                await _folders.removeAt(index);
                setState(() {
                });
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  @override
  void initState() {
    _folders=[];
    getDir();
    getFiles();
    super.initState();
  }
  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        centerTitle: false,
        titleSpacing: 0.0,
        toolbarHeight: 60,
        title: const Padding(
          padding: EdgeInsets.only(left: 3.0 , bottom: 3),
          child: Text("Tools" ,style: TextStyle(color: Colors.black , fontWeight: FontWeight.w500 , fontSize: 20),),
        ) , backgroundColor: const Color(0xfff8f5f0) ,iconTheme: const IconThemeData(color: Colors.black) ,elevation: 0.0,
        actions: [
          searchBar.getSearchAction(context) ,
          IconButton(
            onPressed:(){
              _showMyDialog();
            },
            icon: const Icon(Icons.add_card)),
          IconButton(
              onPressed: (){
              },
              icon: const Icon(CupertinoIcons.folder_circle)),
          IconButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => FirstScreen())),
              icon: const Icon(CupertinoIcons.settings))]);
  }
  void onSubmitted(String value) {
    setState(() => _scaffoldKey.currentState
        ?.showSnackBar(SnackBar(content: Text('You wrote $value!'))));
  }

  _FirstScreen() {
    searchBar =SearchBar(
        inBar: false,
        buildDefaultAppBar: buildAppBar,
        setState: setState,
        onSubmitted: onSubmitted,
        onChanged: (value) {
          setState(() {
            _search = value;
          });
        },
        onCleared: () {
          setState(() {
            _search = "";
          });
        },
        onClosed: () {
          setState(() {
            _search = "";
          });
        });
  }