import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:match_book_front/DetailBook/detail.dart';
import 'package:match_book_front/Home/Home.dart';
import 'package:match_book_front/constants.dart';
import 'dart:async';
import 'dart:convert';

import 'package:match_book_front/models/Book.dart';
import 'package:match_book_front/Profile/profile.dart';

const url = "https://match-book.up.railway.app/api/authentication/";
const String urlImage =
    'https://images-submarino.b2w.io/produtos/01/00/img/128898/3/128898358_2GG.jpg';

class RegisterBook extends StatefulWidget {
  RegisterBook({super.key});
  @override
  _RegisterBookState createState() => _RegisterBookState();
}

class _RegisterBookState extends State<RegisterBook> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController bookController = TextEditingController();
  bool _isLoading = false;

  List<Book> booksList = [];

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Adicione um novo livro",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Row(children: [
                    Expanded(
                      child: TextField(
                          controller: bookController,
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(
                              labelText: "Títutlo",
                              labelStyle: TextStyle(color: Colors.blueAccent)),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.blueAccent, fontSize: 20.0)),
                    ),
                    SizedBox(
                      width: 50,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () =>
                            _refreshIndicatorKey.currentState?.show(),
                        style: ElevatedButton.styleFrom(
                          alignment: Alignment.center,
                          //fixedSize: const Size.fromHeight(25)
                        ),
                        child: Icon(Icons.search),
                      ),
                    )
                  ]),
                  RefreshIndicator(
                    key: _refreshIndicatorKey,
                    color: Colors.white,
                    backgroundColor: Colors.blue,
                    strokeWidth: 4.0,
                    onRefresh: (() async =>
                        {await getBooks(bookController.text)}),
                    child: _createListView(),
                  ),
                ],
              )),
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                  );
                },
                icon: Icon(Icons.home),
                color: Colors.grey),
            IconButton(
                onPressed: () {}, icon: Icon(Icons.search), color: Colors.grey),
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Profile()),
                  );
                },
                icon: Icon(Icons.account_box_rounded),
                color: Colors.grey),
          ],
        ));
  }

  Widget _createListView() {
    return Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        thickness: 10,
        child: ListView.separated(
          padding: const EdgeInsets.all(8),
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
          controller: _scrollController,
          shrinkWrap: true,
          itemCount: booksList == null ? 0 : booksList.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: booksList[index].imageLinks != null
                  ? Image.network(_getImageLinks(booksList[index].imageLinks))
                  : Image.asset("imagens/not_found_book.webp"),
              title: Text(booksList[index].name),
              //subtitle: Text('Here is a second line'), author
              trailing: IconButton(
                  onPressed: (() {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                DetailBook(booksList[index])));
                  }),
                  icon: const Icon(Icons.read_more_rounded)),
            );
          },
        ));
  }

  String _getImageLinks(image) {
    String msg = '';
    if (image != null) {
      msg = image['smallThumbnail'];
    }
    return msg;
  }

  Future getBooks(String name) async {
    var urlRequest = '${bookURL}books-api/${name}';
    final response = await http.get(
      Uri.parse(urlRequest),
    );
    if (response.statusCode == 200) {
      List<Book> books = [];
      List<dynamic> list = json.decode(response.body);
      list.forEach((element) => {books.add(Book.fromJson(element))});
      setState(() {
        booksList = books;
      });
    }
  }
}
