import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_expenses_app/models/Transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function deleteTransaction;

  TransactionList(this.transactions, this.deleteTransaction);

  @override
  Widget build(BuildContext context) {
    return transactions.isEmpty ?
        LayoutBuilder(builder: (context, constraints) {
          return Column(
            children: <Widget>[
              Text(
                'No Transactions',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                height: constraints.maxHeight * 0.6,
                child: Image.asset(
                  'assets/Images/unsplash.jpg',
                  fit: BoxFit.cover,
                ),
              )
            ],
          );
        })
      : ListView.builder(
      itemBuilder: (context, index) {
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8,),
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: FittedBox(
                  child: Text('\$${transactions[index].amount}'),
                ),
              ),
            ),
            title: Text(
              transactions[index].title,
              style: Theme.of(context).textTheme.headline6,
            ),
            subtitle: Text(DateFormat.yMMMd().format(transactions[index].date)),
            trailing: MediaQuery.of(context).size.width > 360 ?
            TextButton.icon(
              onPressed: () => deleteTransaction(transactions[index].id),
              icon: Icon(Icons.delete),
              label: Text('Delete'),
              style: TextButton.styleFrom(primary: Theme.of(context).errorColor),
            )
                : IconButton(
              icon: Icon(Icons.delete),
              color: Theme.of(context).errorColor,
              onPressed: () => deleteTransaction(transactions[index].id),
            ),
          ),
        );
      },
      itemCount: transactions.length,
    );
  }
}
