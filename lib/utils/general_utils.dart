import 'package:flutter/material.dart' hide Key;
import 'package:flutter/rendering.dart';
import 'package:soleoserp/ui/res/color_resources.dart';
import 'package:soleoserp/ui/widgets/common_widgets.dart';

Future navigateTo(BuildContext context, String routeName,
    {Object arguments,
    bool clearAllStack: false,
    bool clearSingleStack: false,
    bool useRootNavigator: false,
    String clearUntilRoute}) async {
  if (clearAllStack) {
    await Navigator.of(context, rootNavigator: useRootNavigator)
        .pushNamedAndRemoveUntil(routeName, (route) => false,
            arguments: arguments);
  } else if (clearSingleStack) {
    await Navigator.of(context, rootNavigator: useRootNavigator)
        .popAndPushNamed(routeName, arguments: arguments);
  } else if (clearUntilRoute != null) {
    await Navigator.of(context, rootNavigator: useRootNavigator)
        .pushNamedAndRemoveUntil(
            routeName, ModalRoute.withName(clearUntilRoute),
            arguments: arguments);
  } else {
    return await Navigator.of(context, rootNavigator: useRootNavigator)
        .pushNamed(routeName, arguments: arguments);
  }
}

Future showCommonDialogWithTwoOptions(BuildContext context, String message,
    {String negativeButtonTitle,
    String positiveButtonTitle,
    bool useRootNavigator = true,
    GestureTapCallback onTapOfNegativeButton,
    GestureTapCallback onTapOfPositiveButton}) async {
  ThemeData baseTheme = Theme.of(context);
  await showDialog(
    context: context,
    builder: (context2) {
      return Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: colorWhite,
          ),
          width: double.maxFinite,
          margin: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: BoxConstraints(minHeight: 100),
                padding: EdgeInsets.all(10),
                child: Center(
                  child: SingleChildScrollView(
                    child: Text(
                      message,
                      maxLines: 15,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: baseTheme.textTheme.button,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                child: getCommonDivider(),
              ),
              Container(
                height: 60,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        child: Container(
                          color: Colors.transparent,
                          child: Center(
                            child: Text(
                              negativeButtonTitle,
                              textAlign: TextAlign.center,
                              style: baseTheme.textTheme.button,
                            ),
                          ),
                        ),
                        onTap: onTapOfNegativeButton ??
                            () {
                              Navigator.of(context,
                                      rootNavigator: useRootNavigator)
                                  .pop();
                            },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                      child: getCommonVerticalDivider(),
                    ),
                    Expanded(
                      child: GestureDetector(
                        child: Container(
                          color: Colors.transparent,
                          child: Center(
                            child: Text(
                              positiveButtonTitle,
                              textAlign: TextAlign.center,
                              style: baseTheme.textTheme.button
                                  .copyWith(color: colorPrimaryLight),
                            ),
                          ),
                        ),
                        onTap: onTapOfPositiveButton ??
                            () {
                              Navigator.of(context,
                                      rootNavigator: useRootNavigator)
                                  .pop();
                            },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}

Future showCommonDialogWithSingleOption(
  BuildContext context,
  String message, {
  String positiveButtonTitle = "OK",
  GestureTapCallback onTapOfPositiveButton,
  bool useRootNavigator = true,
  EdgeInsetsGeometry margin: const EdgeInsets.only(left: 20, right: 20),
}) async {
  ThemeData baseTheme = Theme.of(context);

  await showDialog(
    context: context,
    builder: (context2) {
      return Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: colorWhite,
          ),
          width: double.maxFinite,
          margin: margin,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: BoxConstraints(minHeight: 100),
                padding: EdgeInsets.all(10),
                child: Center(
                  child: SingleChildScrollView(
                    child: Text(
                      message,
                      maxLines: 15,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: baseTheme.textTheme.button,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                child: getCommonDivider(),
              ),
              GestureDetector(
                child: Container(
                  height: 60,
                  color: Colors.transparent,
                  child: Center(
                    child: Text(
                      positiveButtonTitle,
                      textAlign: TextAlign.center,
                      style: baseTheme.textTheme.button
                          .copyWith(color: colorPrimaryLight),
                    ),
                  ),
                ),
                onTap: onTapOfPositiveButton ??
                    () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
              )
            ],
          ),
        ),
      );
    },
  );
}

bool shouldPaginate(dynamic scrollInfo,
    {AxisDirection axisDirection: AxisDirection.down}) {
  return scrollInfo is ScrollEndNotification &&
      scrollInfo.metrics.extentAfter == 0 &&
      scrollInfo.metrics.maxScrollExtent > 0 &&
      scrollInfo.metrics.axisDirection == axisDirection;
}

bool shouldPaginateFromController(ScrollController scrollController) {
  final maxScroll = scrollController.position.maxScrollExtent;
  final currentScroll = scrollController.offset;

  if (currentScroll >= (maxScroll * 0.9) &&
      scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
    return true;
  } else {
    return false;
  }
}

MaterialPageRoute getMaterialPageRoute(Widget screen) {
  return MaterialPageRoute(
    builder: (context) {
      return screen;
    },
  );
}
