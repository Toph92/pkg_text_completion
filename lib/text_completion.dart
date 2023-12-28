import 'package:flutter/material.dart';
import 'controler.dart';

class TextCompletion extends StatefulWidget {
  const TextCompletion(
      {super.key,
      required this.controler,
      this.minCharacterNeeded = 0,
      this.listWidth,
      this.listHeight = 100,
      this.hintText = "",
      this.labelText = "",
      this.bgColorPopup = Colors.white});

  final TextCompletionControler controler;
  final int minCharacterNeeded;
  final double? listWidth;
  final double listHeight;
  final String hintText;
  final String labelText;
  final Color bgColorPopup;

  @override
  State<TextCompletion> createState() => _TextCompletionState();
}

class _TextCompletionState extends State<TextCompletion> {
  final GlobalKey textKey = GlobalKey();
  TextEditingController txtControler = TextEditingController();
  OverlayEntry? overlayEntry;
  final GlobalKey overlayKey = GlobalKey();
  double? textFieldWidth;
  String? hintMessage;

  @override
  void initState() {
    super.initState();

    widget.controler.txtFieldValue.addListener(listenerOnValue);
  }

  void listenerOnValue() {
    txtControler.text = widget.controler.txtFieldValue.value ?? '';
  }

  @override
  void dispose() {
    widget.controler.txtFieldValue.removeListener(listenerOnValue);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //textFieldWidth = MediaQuery.of(context).size.width;
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      textFieldWidth = constraints.maxWidth;
      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: TextField(
              key: textKey,
              decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w400,
                      fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  labelText: widget.labelText,
                  isDense: true,
                  border: const OutlineInputBorder(),
                  suffixIcon: txtControler.text.isNotEmpty &&
                          widget.controler.selectedFromList == false
                      ? IconButton(
                          splashRadius: 1,
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            //txtControler.text = "";
                            widget.controler.value = "";
                            hintMessage = null;
                            removeHighlightOverlay();
                            setState(() {});
                            //onRefresh?.call();
                          },
                        )
                      : null),
              controller: txtControler,
              onChanged: (value) {
                widget.controler.selectedFromList = false;
                if (value.trim().length >= widget.minCharacterNeeded) {
                  widget.controler.updateCriteria(value);
                  if (widget.controler.dataSourceFiltered!.isNotEmpty) {
                    hintMessage = null;
                    showPopup(key: textKey);
                  } else {
                    hintMessage = "Aucun résultat";
                    removeHighlightOverlay();
                  }
                } else {
                  removeHighlightOverlay();
                  if (txtControler.text.isNotEmpty &&
                      widget.minCharacterNeeded > 0) {
                    hintMessage =
                        "${widget.minCharacterNeeded} caractère${widget.minCharacterNeeded > 1 ? 's' : ''} min.";
                  } else {
                    hintMessage = null;
                  }
                }
                setState(() {});
              },
            ),
          ),
          if (hintMessage != null)
            Positioned(
                bottom: 0,
                right: 8,
                child: Container(
                  color: Colors.white,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.blue,
                            size: 16,
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            hintMessage!,
                            style: TextStyle(
                                backgroundColor: Colors.white,
                                fontSize: 12,
                                color: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
        ],
      );
    });
  }

  void showPopup({required GlobalKey key}) {
    RenderBox buttonRenderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    createHighlightOverlay(
      position: buttonRenderBox.localToGlobal(Offset.zero),
    );
  }

  void removeHighlightOverlay() {
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  }

  void createHighlightOverlay({
    required Offset position,
  }) {
    double borderRadius = 10;
    double borderWidth = 1;
    double elevation = 6;

    // Remove the existing OverlayEntry.
    removeHighlightOverlay();

    assert(overlayEntry == null);

    overlayEntry = OverlayEntry(
      // Create a new OverlayEntry.
      builder: (BuildContext context) {
        double opa = 0;
        // Align is used to position the highlight overlay
        // relative to the NavigationBar destination.
        return Positioned(
          top: position.dy + 50,
          left: position.dx + 0,
          child: SafeArea(
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                width: widget.listWidth ?? textFieldWidth,
                height: widget.listHeight,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(elevation, elevation),
                        blurRadius: 6.0,
                      ),
                    ],
                    color: widget.bgColorPopup,
                    border: Border.all(
                      color: Colors.grey,
                      width: borderWidth,
                    ),
                    borderRadius:
                        BorderRadius.all(Radius.circular(borderRadius))),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                      Radius.circular(borderRadius - borderWidth)),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ListView.separated(
                            //shrinkWrap: true,
                            itemCount: widget.controler.dataSourceFiltered !=
                                    null
                                ? widget.controler.dataSourceFiltered!.length
                                : 0,
                            separatorBuilder: (context, index) => const Divider(
                              height: 3,
                            ),
                            itemBuilder: (context, index) {
                              return Material(
                                type: MaterialType.transparency,
                                child: ListTile(
                                    horizontalTitleGap: 4,
                                    minLeadingWidth: 0,
                                    contentPadding: const EdgeInsets.only(
                                      left: 4,
                                      right: 4,
                                    ),
                                    visualDensity: const VisualDensity(
                                        horizontal: 0, vertical: -4),
                                    dense: true,
                                    hoverColor: Colors.yellow,
                                    onTap: () {
                                      widget.controler.onUpdate?.call(widget
                                          .controler
                                          .dataSourceFiltered![index]);
                                      removeHighlightOverlay();
                                      widget.controler.selectedFromList = true;
                                      setState(() {});
                                    },
                                    leading: widget
                                            .controler
                                            .dataSourceFiltered![index]
                                            .fuzzySearch
                                        ? Icon(
                                            Icons.help,
                                            size: 24,
                                            // les ravages de l'alcool :
                                            color: Colors.blue.withOpacity(
                                                (opa = ((widget.controler.dataSourceFiltered![
                                                                        index])
                                                                    .fuzzyScore ??
                                                                1.0) *
                                                            2) >
                                                        1
                                                    ? 1
                                                    : opa),
                                          )
                                        : const SizedBox(),
                                    title: widget
                                        .controler.dataSourceFiltered![index]
                                        .title(widget.controler)),
                              );
                            },
                          ),
                        ),
                      ),
                      const Divider(
                        height: 1,
                      ),
                      if (widget.controler.dataSourceFiltered != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            children: [
                              Text(
                                "${widget.controler.dataSourceFiltered!.length}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                "résultat${widget.controler.dataSourceFiltered!.length > 1 ? 's' : ''}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey),
                              ),
                              if (widget.controler.dataSourceFiltered!
                                      .isNotEmpty &&
                                  widget.controler.dataSourceFiltered!.first
                                      .fuzzySearch) ...[
                                const SizedBox(
                                  width: 10,
                                ),
                                const Icon(Icons.question_mark_sharp,
                                    size: 16, color: Colors.blue),
                                const Text(
                                  ": recherche approchante",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey),
                                )
                              ]
                            ],
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    // Add the OverlayEntry to the Overlay.
    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
  }
}