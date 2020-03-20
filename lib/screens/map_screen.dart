import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:ravel/constants.dart';
import 'package:ravel/models/helper_methods.dart';
import 'package:ravel/screens/add_book_content_screens.dart';
import 'package:ravel/models/book.dart';
import 'package:provider/provider.dart';
import 'package:ravel/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:ravel/services/geocoding_service.dart';
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
                onTap: (LatLng position) {
                  _onTapMap(context: context, position: position);
                },
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

  _onTapMap({BuildContext context, LatLng position}) async {
    String loggedInUid = Provider.of<String>(context, listen: false);

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
      isScrollControlled: true,
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
          ImageConfiguration(devicePixelRatio: 10), 'assets/images/book.png');
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
  DateTime fromDate = DateTime.now().add(Duration(days: 5));
  DateTime toDate = DateTime.now().add(Duration(days: 7));
  bool isAddButtonEnabled = true;

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
    fromDate = dates[0];
    toDate = dates[1];
    if ((fromDate == null || toDate == null) && isAddButtonEnabled) {
      setState(() {
        isAddButtonEnabled = false;
      });
    } else if (fromDate != null && toDate != null && !isAddButtonEnabled) {
      setState(() {
        isAddButtonEnabled = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 35, 10, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 60,
              child: FutureBuilder(
                future: futureCity,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return CupertinoActivityIndicator();
                  }
                  if (snapshot.hasError) {
                    return Container(
                      color: Colors.red,
                      child: const Text('Something went wrong'),
                    );
                  }
                  String city = snapshot.data;
                  if (city == null || city == '') {
                    city = 'Unknown Place';
                  }

                  return Text(
                    city,
                    style: kSheetTitle,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            DateRangePicker(
              initialFirstDate: fromDate,
              initialLastDate: toDate,
              firstDate: DateTime.utc(1950, 7, 20, 20, 18, 04),
              lastDate: DateTime.utc(2040, 7, 20, 20, 18, 04),
              onChanged: _onChanged,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                CupertinoButton(
                  padding: EdgeInsets.all(0),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'OpenSansBold',
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                RightButton(
                  isEnabled: isAddButtonEnabled,
                  text: 'Add',
                  onPressed: () async {
                    String city = await futureCity;
                    int differenceInDays = toDate.difference(fromDate).inDays;
                    int numberOfPages = differenceInDays + 1;

                    Book book = Book(
                        ownerUid: widget.loggedInUid,
                        city: city,
                        fromDate: fromDate,
                        toDate: toDate,
                        title: 'Title',
                        numberOfPages: numberOfPages,
                        content: 'Content',
                        location: GeoPoint(widget.bookPosition.latitude,
                            widget.bookPosition.longitude),
                        whenCreated: FieldValue.serverTimestamp());

                    final firestoreService =
                        Provider.of<FirestoreService>(context, listen: false);
                    await firestoreService.addBookWithPages(book: book);
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
                )
              ],
            )
          ],
        ),
      ),
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
              '${HelperMethods.convertTimeToString(time: book.fromDate)}     -     ${HelperMethods.convertTimeToString(time: book.toDate)}',
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
                  isEnabled: true,
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
  final bool isEnabled;

  RightButton(
      {@required this.text,
      @required this.onPressed,
      @required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        color: isEnabled ? kLightGreen : CupertinoColors.systemGrey5,
        borderRadius: BorderRadius.circular(30),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 25,
            fontFamily: 'OpenSansBold',
            color: isEnabled ? kGreen : CupertinoColors.inactiveGray,
          ),
        ),
        onPressed: () {
          if (isEnabled) {
            onPressed();
          }
        });
  }
}

class ChooseTimeDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Container(
            color: Colors.blue,
            height: 300,
            width: 200,
          ),
        );
      },
    );
  }
}
