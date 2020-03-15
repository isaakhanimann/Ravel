import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:ravel/constants.dart';
import 'package:ravel/screens/add_book_content_screens.dart';
import 'package:ravel/models/book.dart';
import 'package:provider/provider.dart';
import 'package:ravel/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:ravel/services/geocoding_service.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:ravel/widgets/date_range_picker.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  BitmapDescriptor customPin;
  Stream<List<Book>> streamOfBooks;
  bool showLoading = true;

  @override
  void initState() {
    super.initState();
    _setCustomPin();
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    final loggedInUid = Provider.of<String>(context, listen: false);
    streamOfBooks = firestoreService.getStreamOfBooks(uid: loggedInUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: StreamBuilder(
        stream: streamOfBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.none) {
            showLoading = true;
          }

          showLoading = false;

          final List<Book> books = snapshot.data;

          Set<Marker> markers = _convertBooksToMarkers(books: books);

          return Stack(
            children: <Widget>[
              GoogleMap(
                onTap: _onTapMap,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                compassEnabled: false,
                initialCameraPosition:
                    CameraPosition(target: LatLng(24.142, -110.321), zoom: 4),
                markers: markers,
              ),
              if (showLoading) Center(child: CupertinoActivityIndicator())
            ],
          );
        },
      ),
    );
  }

  _onTapMap(LatLng position) async {
    String loggedInUid = Provider.of<String>(context, listen: false);

//    final List<DateTime> picked = await DateRagePicker.showDatePicker(
//        context: context,
//        initialFirstDate: new DateTime.now(),
//        initialLastDate: (new DateTime.now()).add(new Duration(days: 7)),
//        firstDate: new DateTime(2015),
//        lastDate: new DateTime(2022));
//    if (picked != null && picked.length == 2) {
//      print(picked);
//    }

    _showBottomSheet(
      child: DayPickerSheet(
        bookPosition: position,
        loggedInUid: loggedInUid,
      ),
    );
  }

  _onBookTapped({@required Book book}) {
    _showBottomSheet(
        child: BookInfoSheet(
      book: book,
    ));
  }

  _showBottomSheet({@required Widget child}) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      backgroundColor: Colors.white,
      builder: (context) => child,
    );
  }

  Set<Marker> _convertBooksToMarkers({List<Book> books}) {
    if (books == null) {
      return Set.from([]);
    }
    List<Marker> markersList = books
        .map(
          (book) => Marker(
            markerId: MarkerId(UniqueKey().toString()),
            icon: customPin,
            position: LatLng(book.location.latitude, book.location.longitude),
            draggable: true,
            onTap: () {
              _onBookTapped(book: book);
            },
          ),
        )
        .toList();
    return Set.from(markersList);
  }

  _setCustomPin() async {
    if (customPin == null) {
      BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: 10), 'assets/book.png');
      customPin = icon;
    }
  }
}

class DayPickerSheet extends StatefulWidget {
  final LatLng bookPosition;
  final String loggedInUid;

  DayPickerSheet({@required this.bookPosition, @required this.loggedInUid});

  @override
  _DayPickerSheetState createState() => _DayPickerSheetState();
}

class _DayPickerSheetState extends State<DayPickerSheet> {
  Future<String> futureCity;
  int selectedNumber = 2;

  @override
  void initState() {
    super.initState();
    final geocodingService =
        Provider.of<GeocodingService>(context, listen: false);
    futureCity = geocodingService.getCity(
        latitude: widget.bookPosition.latitude,
        longitude: widget.bookPosition.longitude);
  }

  _onChanged(List<DateTime> dates) {
    print('dates changed!!!!!!!!!!!!!!!!!');
    print(dates);
  }

  @override
  Widget build(BuildContext context) {
    return DateRangePicker(
      initialFirstDate: DateTime.now(),
      initialLastDate: DateTime.utc(2020, 3, 20, 20, 18, 04),
      firstDate: DateTime.utc(2018, 7, 20, 20, 18, 04),
      lastDate: DateTime.utc(2022, 7, 20, 20, 18, 04),
    );

//    return SafeArea(
//      child: Container(
//        padding: const EdgeInsets.fromLTRB(20, 35, 20, 8),
//        child: Column(
//          mainAxisSize: MainAxisSize.min,
//          children: <Widget>[
//            SizedBox(
//              height: 60,
//              child: FutureBuilder(
//                future: futureCity,
//                builder: (context, snapshot) {
//                  if (snapshot.connectionState != ConnectionState.done) {
//                    return CupertinoActivityIndicator();
//                  }
//                  if (snapshot.hasError) {
//                    return Container(
//                      color: Colors.red,
//                      child: const Text('Something went wrong'),
//                    );
//                  }
//                  String city = snapshot.data;
//                  if (city == null || city == '') {
//                    city = 'Unknown Place';
//                  }
//
//                  return Text(city, style: kSheetTitle);
//                },
//              ),
//            ),
//            SizedBox(
//              height: 20,
//            ),
//            Text(
//              'How many days do you want to spend there?',
//              style: TextStyle(
//                  fontSize: 25, fontFamily: 'CatamaranSemiBold', color: kGrey),
//              textAlign: TextAlign.center,
//            ),
//            DatePickerSection(
//              onSelectedItemChanged: _onSelectedItemChanged,
//              initialNumberSelected: selectedNumber,
//            ),
//            Row(
//              mainAxisAlignment: MainAxisAlignment.spaceAround,
//              children: <Widget>[
//                CupertinoButton(
//                  child: Text(
//                    'Cancel',
//                    style: TextStyle(
//                      fontSize: 20,
//                      fontFamily: 'OpenSansBold',
//                      color: Colors.black,
//                    ),
//                  ),
//                  onPressed: () {
//                    Navigator.pop(context);
//                  },
//                ),
//                RightButton(
//                  text: 'Add',
//                  onPressed: () async {
//                    Book book = await _addBook(position: widget.bookPosition);
//                    Navigator.pop(context);
//                    Navigator.of(context).push(
//                      CupertinoPageRoute<void>(
//                        builder: (context) {
//                          return AddBookContentScreens(
//                            book: book,
//                          );
//                        },
//                      ),
//                    );
//                  },
//                )
//              ],
//            )
//          ],
//        ),
//      ),
//    );
  }

  Future<Book> _addBook({LatLng position}) async {
    String city = await futureCity;

    Book book = Book(
        ownerUid: widget.loggedInUid,
        city: city,
        title: 'Title',
        numberOfPages: selectedNumber,
        content: 'Content',
        location: GeoPoint(position.latitude, position.longitude),
        whenCreated: FieldValue.serverTimestamp());
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    await firestoreService.addBookWithPages(book: book);

    return book;
  }

  _onSelectedItemChanged(int indexOfItem) {
    selectedNumber = indexOfItem + 1;
  }
}

class DatePickerSection extends StatefulWidget {
  final Function onSelectedItemChanged;
  final int initialNumberSelected;

  DatePickerSection(
      {@required this.onSelectedItemChanged,
      @required this.initialNumberSelected});

  @override
  _DatePickerSectionState createState() => _DatePickerSectionState();
}

class _DatePickerSectionState extends State<DatePickerSection> {
  final List<Text> items = [];
  FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController =
        FixedExtentScrollController(initialItem: widget.initialNumberSelected);
    for (int i = 1; i < 21; i++) {
      items.add(Text(
        i.toString(),
        style: TextStyle(fontFamily: 'OpenSansRegular', color: kGrey),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: CupertinoPicker(
          scrollController: _scrollController,
          backgroundColor: Colors.white,
          itemExtent: 30,
          onSelectedItemChanged: widget.onSelectedItemChanged,
          children: items),
    );
  }
}

class BookInfoSheet extends StatelessWidget {
  final Book book;

  BookInfoSheet({@required this.book});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 35, 20, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              book.city,
              style: kSheetTitle,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Time of stay: ${book.numberOfPages.toString()} days',
              style: TextStyle(
                fontFamily: 'OpenSansRegular',
                fontSize: 20,
                color: kGrey,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                CupertinoButton(
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'OpenSansBold',
                      color: kRed,
                    ),
                  ),
                  onPressed: () async {
                    final firestoreService =
                        Provider.of<FirestoreService>(context, listen: false);
                    await firestoreService.deleteBook(book: book);
                    Navigator.pop(context);
                  },
                ),
                RightButton(
                  text: 'Edit',
                  onPressed: () async {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      CupertinoPageRoute<void>(
                        builder: (context) {
                          return AddBookContentScreens(
                            book: book,
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class RightButton extends StatelessWidget {
  final String text;
  final Function onPressed;

  RightButton({@required this.text, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: kLightGreen,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 25,
              fontFamily: 'OpenSansBold',
              color: kGreen,
            ),
          ),
        ),
        onPressed: onPressed);
  }
}
