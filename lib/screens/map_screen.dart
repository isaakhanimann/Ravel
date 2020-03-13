import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:ravel/constants.dart';
import 'package:ravel/screens/add_book_content_screen.dart';
import 'package:ravel/models/book.dart';
import 'package:provider/provider.dart';
import 'package:ravel/services/firestore_service.dart';
import 'package:flutter/material.dart';

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
    return StreamBuilder(
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
              initialCameraPosition:
                  CameraPosition(target: LatLng(24.142, -110.321), zoom: 4),
              markers: markers,
            ),
            if (showLoading) Center(child: CupertinoActivityIndicator())
          ],
        );
      },
    );
  }

  _onTapMap(LatLng position) async {
    String loggedInUid = Provider.of<String>(context, listen: false);
    showGeneralDialog(
        barrierColor: Colors.white.withOpacity(0.3),
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: widget,
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 150),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return DayPickerDialog(
            bookPosition: position,
            loggedInUid: loggedInUid,
          );
        });
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
            infoWindow: InfoWindow(
                title: 'Description of Marker',
                snippet: 'Click to Edit',
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      builder: (context) {
                        return AddBookContentScreen(
                          book: book,
                        );
                      },
                    ),
                  );
                }),
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

class DayPickerDialog extends StatefulWidget {
  final LatLng bookPosition;
  final String loggedInUid;

  DayPickerDialog({@required this.bookPosition, @required this.loggedInUid});

  @override
  _DayPickerDialogState createState() => _DayPickerDialogState();
}

class _DayPickerDialogState extends State<DayPickerDialog> {
  final List<Text> items = [];
  FixedExtentScrollController scrollController;
  int selectedNumber = 2;

  @override
  void initState() {
    super.initState();
    scrollController = FixedExtentScrollController(initialItem: selectedNumber);
    for (int i = 1; i < 21; i++) {
      items.add(Text(
        i.toString(),
        style: TextStyle(fontFamily: 'OpenSansRegular', color: kDarkGrey),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 35, 20, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'How many days do you want to spend there?',
              style: TextStyle(
                fontSize: 25,
                fontFamily: 'CatamaranBold',
                height: 1.3,
                color: kDarkGrey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 120,
              child: CupertinoPicker(
                  scrollController: scrollController,
                  backgroundColor: kBrightYellow,
                  itemExtent: 30,
                  onSelectedItemChanged: _onSelectedItemChanged,
                  children: items),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                CupertinoButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'OpenSansRegular',
                      color: kGreen,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CupertinoButton(
                  child: Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'OpenSansBold',
                      color: kGreen,
                    ),
                  ),
                  onPressed: () async {
                    Book book = await _addBook(position: widget.bookPosition);
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      CupertinoPageRoute<void>(
                        builder: (context) {
                          return AddBookContentScreen(
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
      backgroundColor: kBrightYellow,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
    );
  }

  Future<Book> _addBook({LatLng position}) async {
    Book book = Book(
        ownerUid: widget.loggedInUid,
        title: 'Title',
        numberOfPages: selectedNumber,
        content: 'Content',
        location: GeoPoint(position.latitude, position.longitude),
        whenCreated: FieldValue.serverTimestamp());
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    await firestoreService.updateBook(book: book);

    return book;
  }

  _onSelectedItemChanged(int indexOfItem) {
    selectedNumber = indexOfItem + 1;
  }
}
