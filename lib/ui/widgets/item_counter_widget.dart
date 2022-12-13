import 'package:flutter/material.dart';

class ItemCounterWidgetForCart extends StatefulWidget {
  final Function onAmountChanged;
  int amount;

  ItemCounterWidgetForCart({Key key, this.onAmountChanged, this.amount})
      : super(key: key);

  @override
  _ItemCounterWidgetState createState() => _ItemCounterWidgetState();
}

class _ItemCounterWidgetState extends State<ItemCounterWidgetForCart> {
  int amount = 1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print("dfjdjfjdf56" + widget.amount.toString());
    amount = widget.amount != null ? widget.amount : 1;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        iconWidget(Icons.remove,
            iconColor: Colors.black, onPressed: decrementAmount),
        SizedBox(width: 10),
        Container(
            width: 30,
            child: Center(
                child: getText(
              text: amount.toString(),
              fontSize: 15,
              isBold: true,
              color: Colors.black,
            ))),
        SizedBox(width: 10),
        iconWidget(Icons.add,
            iconColor: Colors.black, onPressed: incrementAmount)
      ],
    );
  }

  void incrementAmount() {
    setState(() {
      amount = amount + 1;
      updateParent();
    });
  }

  void decrementAmount() {
    if (amount <= 1) return;
    setState(() {
      amount = amount - 1;
      updateParent();
    });
  }

  void updateParent() {
    if (widget.onAmountChanged != null) {
      widget.onAmountChanged(amount);
    }
  }

  Widget iconWidget(IconData iconData, {Color iconColor, onPressed}) {
    return GestureDetector(
      onTap: () {
        if (onPressed != null) {
          onPressed();
        }
      },
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: Color(0xffE2E2E2),
          ),
        ),
        child: Center(
          child: Icon(
            iconData,
            color: iconColor ?? Colors.black,
            size: 25,
          ),
        ),
      ),
    );
  }

  Widget getText(
      {String text,
      double fontSize,
      bool isBold = false,
      color = Colors.black}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        color: color,
      ),
    );
  }
}
