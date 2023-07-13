import 'package:flutter/material.dart';

class CustomRoute extends MaterialPageRoute {
  final Widget page;
  CustomRoute({required this.page}):super(builder: (context) => page);

  @override
  // TODO: implement settings
  RouteSettings get settings => RouteSettings(name: page.runtimeType.toString());
}

class CustomRouteHero extends PageRouteBuilder {
  final Widget page;
  CustomRouteHero({required this.page})
      : super(
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) =>
      page,
      transitionsBuilder: (BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child) =>
          FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(animation),
            child: child,
          ),
      opaque: true,
      transitionDuration: Duration(milliseconds: 600));

  @override
  // TODO: implement settings
  RouteSettings get settings => RouteSettings(name: page.runtimeType.toString());
}

class CustomRouteDialog extends PageRouteBuilder {
  final Widget page;
  CustomRouteDialog({required this.page})
      : super(
      pageBuilder: (context, animation,
          secondaryAnimation) =>
      page,
      transitionsBuilder: (context,
          animation,
          secondaryAnimation,
          child) =>
          FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(animation),
            child: child,
          ),
      opaque: false);
}