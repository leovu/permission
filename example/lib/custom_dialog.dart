

import 'package:flutter/material.dart';
import 'package:permission_example/custom_navigator.dart';

class CustomDialog extends StatelessWidget {

  final Widget screen;
  final bool bottom;
  final bool cancelable;

  const CustomDialog({Key? key,
    required this.screen,
    this.bottom = false,
    this.cancelable = true,
  }):assert(screen != null && cancelable != null), super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CustomScaffold(
      backgroundColor: Colors.black.withOpacity(0.3),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              GestureDetector(
                onTap: cancelable?() => CustomNavigator.pop(context):null,
              ),
              Column(
                mainAxisAlignment: bottom?MainAxisAlignment.end:MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: screen,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomScaffold extends StatelessWidget {

  final Widget? body;
  final String? title;
  final Color? backgroundColor;
  final bool isBottomSheet;

  const CustomScaffold({Key? key,
    this.body,
    this.title,
    this.backgroundColor,
    this.isBottomSheet = false,
  }) : super(key: key);

  Widget _buildBody(BuildContext context){
    return Scaffold(
        appBar: title == null? null: AppBar(
          title: Text(
            title??"",
          ),
          elevation: 0.0,
        ),
        backgroundColor: backgroundColor ?? Colors.white,
        body: body,
        resizeToAvoidBottomInset: !isBottomSheet
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: _buildBody(context));
  }
}

class CustomPopupDialog extends StatelessWidget {

  final Widget child;
  final bool isExpanded;

  const CustomPopupDialog({Key? key,
    required this.child,
    this.isExpanded = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: isExpanded?Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20.0))
        ),
        height: MediaQuery.of(context).size.height * 0.5,
        child: child,
      ):Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20.0))
        ),
        child: child,
      ),
    );
  }
}