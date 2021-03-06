import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:digital_receipt/models/receipt.dart';
import 'package:digital_receipt/screens/no_internet_connection.dart';
import 'package:digital_receipt/screens/receipt_screen.dart';
import 'package:digital_receipt/services/CarouselIndex.dart';
import 'package:digital_receipt/utils/connected.dart';
import 'package:digital_receipt/widgets/app_textfield.dart';
import 'package:digital_receipt/widgets/date_time_input_textField.dart';
import 'package:digital_receipt/widgets/submit_button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'button_loading_indicator.dart';
import 'package:digital_receipt/services/api_service.dart';

class CreateReceiptStep2 extends StatefulWidget {
  CreateReceiptStep2({
    this.carouselController,
    this.carouselIndex,
  });
  final CarouselController carouselController;
  final CarouselIndex carouselIndex;

  @override
  _CreateReceiptStep2State createState() => _CreateReceiptStep2State();
}

class _CreateReceiptStep2State extends State<CreateReceiptStep2> {
  ApiService _apiService = ApiService();
  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  TextEditingController _dateTextController = TextEditingController();
  TextEditingController _receiptNumberController = TextEditingController();
  TextEditingController _hexCodeController = TextEditingController()
    ..text = "F14C4C";
  TextEditingController _sellerNameController = TextEditingController();

  final FocusNode _receiptNumberFocus = FocusNode();
  final FocusNode _dateTextFocus = FocusNode();
  final FocusNode _hexCodeFocus = FocusNode();

  bool autoReceiptNo = true;
  String fontVal = "100";
  DateTime date = DateTime.now();
  final picker = ImagePicker();

  List<String> receiptTemplate = [
    'assets/images/Group 168 (1).png',
    'assets/images/Group 169 (1).png',
    'assets/images/Group 172 (1).png',
  ];

  @override
  void initState() {
    super.initState();
    setSellerName();
  }

  void setSellerName() async {
    var user = await _apiService.getUserInfo();
    _sellerNameController.text = user["name"] ?? '';
  }

  @override
  void dispose() {
    _receiptNumberFocus.dispose();
    _dateTextFocus.dispose();
    _hexCodeFocus.dispose();
    super.dispose();
  }

  Future getImageSignature() async {
    PermissionStatus status = await Permission.storage.status;
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    print("file size is :");
    print(File(pickedFile.path).lengthSync());
    if (pickedFile != null) {
      setState(() {
        Provider.of<Receipt>(context, listen: false)
            .setSignature(pickedFile.path);
      });
    } else {
      print("no file");
    }
  }

  setPreReceipt(String result) {
    var temp = json.decode(result)['receiptData'];
    Provider.of<Receipt>(context, listen: false).setIssueDate(temp['date']);
    Provider.of<Receipt>(context, listen: false)
        .setNumber(temp['receipt_number']);
    Provider.of<Receipt>(context, listen: false).receiptId = temp['id'];
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    _dateTextController.text = DateFormat('dd-MM-yyyy').format(date);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 14,
            ),
            Text(
              'Customization',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                fontSize: 22,
                color: Colors.black,
              ),
            ),
            SizedBox(
              height: 3,
            ),
            Text(
              'Tweak the look and feel to your receipt',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.normal,
                letterSpacing: 0.3,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            SizedBox(
              height: 24,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: map<Widget>([1, 1, 2], (index, url) {
                    print(index);
                    return GestureDetector(
                      onTap: () {
                        widget.carouselController.animateToPage(index);
                      },
                      child: Row(
                        children: <Widget>[
                          Container(
                            height: 2,
                            width: 10,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: widget.carouselIndex.index == index
                                    ? Color(0xFF25CCB3)
                                    : Color.fromRGBO(0, 0, 0, 0.12),
                                boxShadow: [
                                  BoxShadow(
                                      offset: Offset(0, 3),
                                      blurRadius: 6,
                                      color: Color.fromRGBO(0, 0, 0, 0.16))
                                ]),
                          ),
                          index != 2 ? SizedBox(width: 10) : SizedBox.shrink()
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
            SizedBox(
              height: 24,
            ),
            /* Text(
              'Add receipt No (Optional)',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.normal,
                letterSpacing: 0.3,
                fontSize: 13,
                color: Color.fromRGBO(0, 0, 0, 0.6),
              ),
            ),
            SizedBox(height: 5),
            AppTextFieldForm(
              focusNode: _receiptNumberFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (value) =>
                  _changeFocus(from: _receiptNumberFocus, to: _dateTextFocus),
              controller: _receiptNumberController,
            ),
            SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Auto generate receipt No',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.normal,
                    letterSpacing: 0.3,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Checkbox(
                  value: Provider.of<Receipt>(context).shouldGenReceiptNo(),
                  onChanged: (val) {
                    setState(() {
                      Provider.of<Receipt>(context, listen: false)
                          .toggleAutoGenReceiptNo();
                    });
                  },
                )
              ],
            ),
            SizedBox(
              height: 32,
            ), */
            Text(
              'Date',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.normal,
                letterSpacing: 0.3,
                fontSize: 13,
                color: Color.fromRGBO(0, 0, 0, 0.6),
              ),
            ),
            SizedBox(height: 5),
            DateTimeInputTextField(
                focusNode: _dateTextFocus,
                controller: _dateTextController,
                onTap: () async {
                  final DateTime picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: date.add(Duration(days: -20)),
                    lastDate: date.add(Duration(days: 365)),
                  );

                  _dateTextFocus.unfocus();
                  if (picked != null && picked != date) {
                    setState(() {
                      date = picked;
                      print(DateTime.now());
                    });
                  }
                }),
            SizedBox(
              height: 20,
            ),
            Text(
              'Seller\'s name',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.normal,
                letterSpacing: 0.3,
                fontSize: 13,
                color: Color.fromRGBO(0, 0, 0, 0.6),
              ),
            ),
            SizedBox(height: 5),
            TextFormField(
              controller: _sellerNameController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(17),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: Color(0xFFC8C8C8),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(),
                errorStyle: TextStyle(height: 0.5),
              ),
            ),
/*  SizedBox(
                    height: 30,
                  ),
                  DropdownButtonFormField<String>(
                    value: fontVal,
                    items: ['100', '200', '300', '400', '500']
                        .map((val) => DropdownMenuItem(
                              child: Text(val.toString()),
                              value: val,
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        fontVal = val;
                      });
                    },
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(15),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                          color: Color(0xFFC8C8C8),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(),
                      //hintText: hintText,
                      hintStyle: TextStyle(
                        color: Color(0xFF979797),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    iconEnabledColor: Color.fromRGBO(0, 0, 0, 0.87),
                    hint: Text(
                      'Select font',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                        fontSize: 16,
                        color: Color(0xFF1B1B1B),
                      ),
                    ),
                  ), */
            SizedBox(
              height: 35,
            ),
            /* SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: FlatButton(
                      onPressed: getImageSignature,
                      shape: RoundedRectangleBorder(
                          side:
                              BorderSide(color: Color(0xFF25CCB3), width: 1.5),
                          borderRadius: BorderRadius.circular(5)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Upload signature',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.normal,
                              letterSpacing: 0.3,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 7),
                          Icon(
                            Icons.file_upload,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Your Signature should be taken on a clear white paper and have a max size of 3MB (Optional)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.3,
                        fontSize: 14,
                        color: Color.fromRGBO(0, 0, 0, 0.6),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 35,
                  ),*/
            Row(
              children: <Widget>[
                Text(
                  'Choose a color (optional)',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 12),
                Text(_hexCodeController.text.toUpperCase()),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 33,
              child: SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ColorButton(
                        color: Colors.red,
                        onPressed: () {
                          setState(() {
                            _hexCodeController.text = 'F14C4C';
                          });
                        },
                      ),
                      ColorButton(
                        color: Color(0xFF539C30),
                        onPressed: () {
                          setState(() {
                            _hexCodeController.text = '539C30';
                          });
                        },
                      ),
                      ColorButton(
                        color: Color(0xFF2C33D5),
                        onPressed: () {
                          setState(() {
                            _hexCodeController.text = '2C33D5';
                          });
                        },
                      ),
                      ColorButton(
                        color: Color(0xFFE7D324),
                        onPressed: () {
                          setState(() {
                            _hexCodeController.text = 'E7D324';
                          });
                        },
                      ),
                      ColorButton(
                        color: Color(0xFFC022B1),
                        onPressed: () {
                          setState(() {
                            _hexCodeController.text = 'C022B1';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Or type brand Hex code here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.3,
                  fontSize: 14,
                  color: Color.fromRGBO(0, 0, 0, 0.6),
                ),
              ),
            ),
            SizedBox(height: 20),
            AppTextFieldForm(
              focusNode: _hexCodeFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (value) => _hexCodeFocus.unfocus(),
              controller: _hexCodeController,
              hintText: 'Enter Brand color hex code',
              hintColor: Color.fromRGBO(0, 0, 0, 0.38),
              borderWidth: 1.5,
            ),

            SizedBox(height: 37),
           /*  Text(
              'Select a receipt',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
                fontSize: 16,
                color: Color.fromRGBO(0, 0, 0, 0.87),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 200,
              width: double.infinity,
              child: ListView.builder(
                itemCount: receiptTemplate.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Scaffold(
                                backgroundColor: Colors.white,
                                appBar: AppBar(
                                  title: Text(
                                    'Preview',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Montserrat',
                                      letterSpacing: 0.03,
                                    ),
                                  ),
                                ),
                                body: SizedBox.expand(
                                  child: Stack(
                                    children: <Widget>[
                                      SingleChildScrollView(
                                        child: SizedBox(
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: ListView.builder(
                                            itemCount: receiptTemplate.length,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Image.asset(
                                                  
                                                  receiptTemplate[index],
                                                  fit: BoxFit.cover,
                                                  height: double.infinity,
                                                  width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: SubmitButton(
                                              title: 'Select',
                                              backgroundColor:
                                                  Color(0xFF0B57A7),
                                              textColor: Colors.white,
                                              onPressed: () {},
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      child: SizedBox(
                        height: 200,
                        width: 150,
                        child: Stack(
                          children: <Widget>[
                            Container(
                              height: 200,
                              width: 150,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  image: DecorationImage(
                                      image: AssetImage(receiptTemplate[index]),
                                      fit: BoxFit.cover),
                                  color: Colors.white),
                            ),
                            Container(
                              height: 200,
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                image: DecorationImage(
                                  image: AssetImage(''),
                                ),
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ), */
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Add paid stamp',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                    fontSize: 16,
                    color: Color.fromRGBO(0, 0, 0, 0.87),
                  ),
                ),
                Checkbox(
                  value: Provider.of<Receipt>(context, listen: false)
                      .enablePaidStamp(),
                  onChanged: (val) {
                    setState(() {
                      Provider.of<Receipt>(context, listen: false)
                          .togglePaidStamp();
                    });
                  },
                )
              ],
            ),
            SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Save as preset',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                    fontSize: 16,
                    color: Color.fromRGBO(0, 0, 0, 0.87),
                  ),
                ),
                Switch(
                  value: Provider.of<Receipt>(context, listen: false)
                      .enablePreset(),
                  onChanged: (val) {
                    setState(() {
                      Provider.of<Receipt>(context, listen: false)
                          .togglePreset();
                    });
                  },
                ),
              ],
            ),

            SizedBox(height: 40),

            SizedBox(
              height: 50,
              width: double.infinity,
              child: FlatButton(
                color: Color(0xFF0B57A7),
                onPressed: () async {
                  // check the internet
                  var connected = await Connected().checkInternet();
                  if (!connected) {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return NoInternet();
                      },
                    );
                    setState(() {
                      isLoading = false;
                    });
                    return;
                  }
                  setState(() {
                    isLoading = true;
                  });
                  Provider.of<Receipt>(context, listen: false)
                      .setIssueDate(null);
                  Provider.of<Receipt>(context, listen: false)
                      .setColor(hexCode: _hexCodeController.text);
                  Provider.of<Receipt>(context, listen: false).setFont(24);
                  Provider.of<Receipt>(context, listen: false)
                      .setSellerName(_sellerNameController.text);

                  Response result =
                      await Provider.of<Receipt>(context, listen: false)
                          .saveReceipt();
                  if (result.statusCode == 200) {
                    setState(() {
                      isLoading = false;
                    });
                    setPreReceipt(result.body);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReceiptScreen(),
                      ),
                    );
                    Fluttertoast.showToast(
                        msg: "Receipt saved to draft",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  } else {
                    setState(() {
                      isLoading = false;
                    });
                    Fluttertoast.showToast(
                        msg: "$result",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                },
                shape: RoundedRectangleBorder(
                    //side: BorderSide(color: Color(0xFF0B57A7), width: 1.5),
                    borderRadius: BorderRadius.circular(5)),
                child: isLoading
                    ? ButtonLoadingIndicator(
                        color: Colors.white,
                        width: 20,
                        height: 20,
                      )
                    : Text(
                        'Generate Receipt',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            // SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  void _changeFocus({FocusNode from, FocusNode to}) {
    from.unfocus();
    FocusScope.of(context).requestFocus(to);
  }
}

class ColorButton extends StatelessWidget {
  const ColorButton({
    Key key,
    this.onPressed,
    this.color,
  }) : super(key: key);

  final Function onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 33,
      width: 33,
      child: FlatButton(
        color: color,
        onPressed: onPressed,
        child: SizedBox.shrink(),
      ),
    );
  }
}
