import 'package:flutter/material.dart';
import 'package:permission_example/custom_dialog.dart';
import 'package:permission_example/custom_route.dart';

class CustomNavigator {
  static showCustomPopupDialog(
      BuildContext context,
      Widget child, {
        bool root = true,
        bool isExpanded = false,
        bool cancelable = true,
      }) {
    return push(
        context,
        CustomDialog(
          screen: CustomPopupDialog(
            isExpanded: isExpanded,
            child: child,
          ),
          cancelable: cancelable,
        ),
        opaque: false,
        root: root);
  }
  static push(BuildContext context, Widget screen,
      {bool root = true, bool opaque = true, bool isHero = false}) {
    return Navigator.of(context, rootNavigator: root).push(opaque
        ? isHero
        ? CustomRouteHero(page: screen)
        : CustomRoute(page: screen,)
        : CustomRouteDialog(page: screen)
    );
  }

  static pop(BuildContext context, {dynamic object, bool root = true}) {
    if (object == null) {
      Navigator.of(context, rootNavigator: root).pop();
    } else {
      Navigator.of(context, rootNavigator: root).pop(object);
    }
  }

  static showCustomBottomDialog(BuildContext context, Widget screen,
      {bool root = true, isScrollControlled = true}) {
    return showModalBottomSheet(
        context: context,
        useRootNavigator: root,
        isScrollControlled: isScrollControlled,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: screen,
          );
        });
  }

  static showCustomAlertDialog(BuildContext context, String content,
      {bool root = true,
        String? title,
        Function? onSubmitted,
        String? textSubmitted,
        String? textSubSubmitted,
        Function? onSubSubmitted,
        bool enableCancelButton = false,
        bool cancelable = true,}) {
    return push(
        context,
        CustomDialog(
          screen: CustomAlertDialog(
            title: title,
            content: content,
            enableCancelButton: enableCancelButton,
            textSubmitted: textSubmitted,
            textSubSubmitted: textSubSubmitted,
            onSubmitted: onSubmitted,
            onSubSubmitted: onSubSubmitted,
          ),
          cancelable: cancelable,
        ),
        opaque: false,
        root: root);
  }
}

class CustomAlertDialog extends StatelessWidget {

  final String? title;
  final String? content;
  final bool? enableCancelButton;
  final String? textSubmitted;
  final String? textSubSubmitted;
  final Function? onSubmitted;
  final Function? onSubSubmitted;

  CustomAlertDialog({
    Key? key,
    this.title,
    this.content,
    this.enableCancelButton,
    this.textSubmitted,
    this.textSubSubmitted,
    this.onSubmitted,
    this.onSubSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white),
      child: CustomListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Text(
            title ?? "Thong bao",
            textAlign: TextAlign.center,
          ),
          Text(
            content ?? "",
            textAlign: TextAlign.center,
          ),
          Row(
            children: [
              if((textSubSubmitted ?? "").isNotEmpty || enableCancelButton!)
                ...[
                  Expanded(child: CustomButton(
                    text: textSubSubmitted ?? "Dong",
                    onTap: onSubSubmitted ?? () => CustomNavigator.pop(context),
                  )),
                  SizedBox(width: 20,),
                ],
              Expanded(child: CustomButton(
                text: textSubmitted ?? "Ok",
                onTap: onSubmitted ?? () => CustomNavigator.pop(context),
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {

  final String? text;
  final bool? expand;
  final Color? color;
  final Function onTap;

  const CustomButton({
    Key? key,
    this.text,
    this.expand,
    this.color,
    required this.onTap,
  }) : super(key: key);

  Widget _buildBody(){
    return ElevatedButton(
      child: Text(
        text ?? "",
      ),
      // style: ElevatedButton.styleFrom(
      //   primary: color ?? AppColors.primary,
      //   padding: EdgeInsets.symmetric(
      //     vertical: AppSizes.minPadding,
      //     horizontal: AppSizes.maxPadding,
      //   ),
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(AppSizes.radius),
      //   ),
      // ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(color ?? Colors.blue),
        padding: MaterialStateProperty.all(EdgeInsets.all(20)),
      ),
      onPressed: onTap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (expand ?? true)?SizedBox(
      width: double.infinity,
      child: _buildBody(),
    ):_buildBody();
  }
}


class CustomListView extends StatefulWidget {

  final ScrollController? controller;
  final List<Widget>? children;
  final EdgeInsetsGeometry? padding;
  final double? separatorPadding;
  final ScrollPhysics? physics;
  final bool? shrinkWrap;
  final Widget? separator;
  final Axis? scrollDirection;
  final bool? showLoadmore;
  final Function? onLoadmore;

  CustomListView({
    this.controller,
    this.children,
    this.padding,
    this.separatorPadding,
    this.physics,
    this.shrinkWrap,
    this.separator,
    this.scrollDirection,
    this.showLoadmore,
    this.onLoadmore,
  });

  @override
  State<CustomListView> createState() => _CustomListViewState();
}

class _CustomListViewState extends State<CustomListView> {

  bool _isLoadmore = false;

  _loadmore() async {
    if (!_isLoadmore) {
      _isLoadmore = true;
      await widget.onLoadmore!();
      _isLoadmore = false;
    }
  }

  Widget _buildBody() {
    List<Widget> children = []..addAll(this.widget.children ?? []);
    if ((widget.showLoadmore ?? false)) {
      children.add(Container());
    }

    return ListView.separated(
        scrollDirection: widget.scrollDirection ?? Axis.vertical,
        controller: widget.controller,
        padding: widget.padding ?? EdgeInsets.all(40),
        physics: widget.physics ?? AlwaysScrollableScrollPhysics(),
        shrinkWrap: widget.shrinkWrap ?? false,
        itemBuilder: (_, index) {
          if (widget.onLoadmore != null && index > (children.length / 2)) {
            _loadmore();
          }
          return children[index];
        },
        separatorBuilder: (_, index) =>
        (widget.separator ?? Container(height: widget.separatorPadding ?? 20,)),
        itemCount: children.length
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }
}