import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:personal_expenses_app/Chart.dart';
import 'package:personal_expenses_app/New%20Transaction.dart';
import 'package:personal_expenses_app/Transaction%20List.dart';

import 'models/Transaction.dart';

void main () {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses',
      home: MyHomePage(),
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.amber,
        errorColor: Colors.red,
        fontFamily: 'Quicksand',
        appBarTheme: AppBarTheme(
          textTheme: ThemeData.light().textTheme.copyWith(
            headline6: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  bool _showChart = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  final List<Transaction> _userTransactions = [
    Transaction(id: 't1', title: 'New Shoes', amount: 69.99, date: DateTime.now()),
    Transaction(id: 't2', title: 'Weekly Groceries', amount: 16.53, date: DateTime.now()),
  ];

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((element) {
      return element.date.isAfter(
          DateTime.now().subtract(
            Duration(days: 7),
          )
      );
    }).toList();
  }

  void _addNewTransaction(String title, double amount, DateTime chosenDate) {
    final newTransaction = Transaction(
        id: DateTime.now().toString(),
        title: title,
        amount: amount,
        date: chosenDate,
    );
    setState(() {
      _userTransactions.add(newTransaction);
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((element) => element.id == id);
    });
  }

  void startAddNewTransaction(BuildContext context) {
    showModalBottomSheet(context: context, builder: (_) {
      return SingleChildScrollView(child: NewTransaction(_addNewTransaction));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final mediaQuery = MediaQuery.of(context);

    final PreferredSizeWidget appBar = Platform.isIOS ? CupertinoNavigationBar(
      middle: Text('Personal Expenses',),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () => startAddNewTransaction(context),
            child: Icon(CupertinoIcons.add),
          )
        ],
      ),
    ) : AppBar(
      title: Text('Personal Expenses',),
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.add),
            onPressed: () => startAddNewTransaction(context)
        )
      ],
    );

    final txListWidget = Container(
      height: (MediaQuery.of(context).size.height - appBar.preferredSize.height - MediaQuery.of(context).padding.top) * 0.7,
      child: TransactionList(_userTransactions, _deleteTransaction),
    );

    final pageBody = SafeArea(child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            if(isLandscape) Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Show Chart:', style: Theme.of(context).textTheme.headline6,),
                Switch.adaptive(
                    value: _showChart, onChanged: (val){
                  setState(() {
                    _showChart = val;
                  });
                }
                ),
              ],
            ),
            if(!isLandscape) Container(
              height: (mediaQuery.size.height- appBar.preferredSize.height - mediaQuery.padding.top) * 0.3,
              child: Chart(_recentTransactions),
            ),
            if(!isLandscape) txListWidget,
            _showChart ? Container(
              height: (mediaQuery.size.height- appBar.preferredSize.height - mediaQuery.padding.top) * 0.3,
              child: Chart(_recentTransactions),
            ) : txListWidget
          ],
        ),
      ),
    );

    return Platform.isIOS ? CupertinoPageScaffold(
      child: pageBody,
      navigationBar: appBar,
    ) :
    Scaffold(
      appBar: appBar,
      body: pageBody,
      floatingActionButton: Platform.isIOS ? Container() : FloatingActionButton(
        child: Icon(Icons.add),onPressed: () => startAddNewTransaction(context),
      ),
    );
  }
}