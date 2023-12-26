import 'dart:async';
import 'dart:math';

import 'package:dsagruppen/chat/ChatCommons.dart';
import 'package:dsagruppen/chat/ChatMessage.dart';
import 'package:dsagruppen/globals.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';

double CHATHEIGHT = 400;
double CHATWIDTH = 300;
double MINIMIZEDICONSIZE = 54;

class ChatOverlay with WidgetsBindingObserver {
  final Stream<ChatMessage> messageStream;
  late OverlayEntry overlayEntry;
  ValueNotifier isVisible = ValueNotifier(false);
  ValueNotifier isMinimized = ValueNotifier(true);
  String gruppeId;
  static Offset _offset = Offset(16, 16);

  Size get widgetIconSize => isMinimized.value
      ? Size(MINIMIZEDICONSIZE, MINIMIZEDICONSIZE)
      : Size(CHATWIDTH, CHATHEIGHT);

  Offset constrainPosition(Offset desiredOffset, Size size) {
    double constrainedX =
        min(desiredOffset.dx, size.width - widgetIconSize.width);
    if (constrainedX < 0) constrainedX = 0;
    double constrainedY =
        min(desiredOffset.dy, size.height - widgetIconSize.height);
    if (constrainedY < 0) constrainedY = 0;
    return Offset(constrainedX, constrainedY);
  }

  ChatOverlay({required this.messageStream, required this.gruppeId}) {
    WidgetsBinding.instance.addObserver(this);
    var context = navigatorKey.currentContext!;
    var size = MediaQuery.of(context).size;
    _offset = Offset(
        16, size.height - widgetIconSize.height); //todo set icon height instead
    overlayEntry = OverlayLayer(_offset, size);
    isVisible.addListener(switchOverlay);
  }

  OverlayEntry OverlayLayer(Offset offset, Size size) {
    isMinimized.addListener(() => recalcPosition());
    return OverlayEntry(builder: (context) {
      return Positioned(
        left: offset.dx,
        top: offset.dy,
        child: ChatOverlayContent(
          gruppeId: gruppeId,
          stream: messageStream,
          isMinimized: isMinimized,
          onDragEnd: (details) {
            offset = _offset = constrainPosition(details.offset, size);
            overlayEntry.markNeedsBuild();
          },
        ),
      );
    });
  }

  void hideOverlay() {
    if (isVisible.value == false) {
      overlayEntry.remove();
    }
  }

  void showOverlay() {
    if (overlayEntry.mounted) {
      return;
    }
    if (isVisible.value == false) {
      isVisible.value = true;
    }
  }

  void switchOverlay() {
    if (isVisible.value == true) {
      BuildContext context = navigatorKey.currentContext!;
      Overlay.of(context).insert(overlayEntry);
    } else {
      overlayEntry.remove();
    }
  }

  void recalcPosition() {
    if (isMinimized.value == false) {
      var context = navigatorKey.currentContext!;
      var size = MediaQuery.of(context).size;

      double newY = _offset.dy - MINIMIZEDICONSIZE + CHATHEIGHT;

      newY = max(0, newY);
      newY = min(size.height - CHATHEIGHT, newY);

      _offset = Offset(_offset.dx, newY);
      overlayEntry.remove();
      overlayEntry = OverlayLayer(_offset, MediaQuery.of(context).size);
      Overlay.of(context).insert(overlayEntry);
      overlayEntry.markNeedsBuild();
    }
  }

  @override
  void didChangeMetrics() {
    // This gets called when the window size changes
    var context = navigatorKey.currentContext;
    print("DIDCHANG");
    if (context != null) {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
      if (ResponsiveBreakpoints.of(context).smallerOrEqualTo(TABLET)) {
        return;
      }
      Offset _offset = Offset(16, MediaQuery.sizeOf(context).height - 54);
      overlayEntry = OverlayLayer(_offset, MediaQuery.of(context).size);
      Overlay.of(context).insert(overlayEntry);
      overlayEntry.markNeedsBuild();
    }
  }

  void dispose() {
    isVisible.removeListener(switchOverlay);
    isMinimized.removeListener(recalcPosition);
    WidgetsBinding.instance.removeObserver(this);
  }
}

class ChatOverlayContent extends StatefulWidget {
  final Stream<ChatMessage> stream;
  final String gruppeId;
  final Function(DraggableDetails) onDragEnd;
  final ValueNotifier isMinimized;

  const ChatOverlayContent(
      {super.key,
      required this.stream,
      required this.gruppeId,
      required this.onDragEnd,
      required this.isMinimized});

  @override
  ChatOverlayContentState createState() => ChatOverlayContentState();
}

class ChatOverlayContentState extends State<ChatOverlayContent> {
  final List<ChatMessage> _messages = [];
  StreamSubscription<ChatMessage>? _streamSubscription;
  TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ValueNotifier<int> lastMessageIndex = ValueNotifier(-1);
  final FocusNode _focusNode = FocusNode();
  //bool isMinimized = true;
  bool isResizingHorizontal = false;
  bool isResizingVertical = false;
  var cursor = SystemMouseCursors.basic;

  @override
  void initState() {
    super.initState();
    _streamSubscription = widget.stream.listen((message) {
      setState(() {
        _messages.add(message);
        ChatCommons.scrollToBottom(
            _scrollController, const Duration(milliseconds: 150));
      });
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  void _updateSize(Offset delta, BuildContext context) {
    setState(() {
      final Size screenSize = MediaQuery.of(context).size;

      const double minWidth = 200;
      const double minHeight = 200;

      double newWidth = CHATWIDTH + (isResizingHorizontal ? delta.dx : 0);
      double newHeight = CHATHEIGHT + (isResizingVertical ? delta.dy : 0);

      //double newWidth = CHATWIDTH + delta.dx;
      //double newHeight = CHATHEIGHT + delta.dy;

      newWidth = max(newWidth, minWidth);
      newHeight = max(newHeight, minHeight);

      newWidth = min(newWidth, screenSize.width - ChatOverlay._offset.dx);
      newHeight = min(newHeight, screenSize.height - ChatOverlay._offset.dy);

        CHATWIDTH = newWidth;

        CHATHEIGHT = newHeight;


    });
  }
  @override
  Widget build(BuildContext context) {
    final Widget currentChatState = widget.isMinimized.value == true
        ? _buildMinimizedIcon(context)
        : _buildChat(context);
    final chatRectWrapper = widget.isMinimized.value == true ? const SizedBox.shrink() : ClipPath(
      clipper: FrameClipper(borderWidth: 10),
      child: MouseRegion(
        cursor: cursor,
        onHover: _updateCursorOnHover,
        onExit: (event) {
          setState(() {
            cursor = SystemMouseCursors.basic;
          });
        },
        child: GestureDetector(
          onPanUpdate: (details) {
            _updateSize(details.delta, context) ;
          },
          child: Container(
            height: CHATHEIGHT,
            width: CHATWIDTH,
            color: Colors.red, // Color of the frame
          ),
        ),
      ),
    );
    return Stack(
      children: [
        Draggable(
            feedback: Stack(children: [currentChatState]),
            childWhenDragging: const SizedBox.shrink(),
            onDragEnd: widget.onDragEnd,
            child: currentChatState),
        chatRectWrapper
      ],
    );
  }

  void _updateCursorOnHover(PointerHoverEvent event) {
    const edgeMargin = 10.0; // Margin size for detecting edges
    final localPosition = event.localPosition;

    bool onLeftEdge = localPosition.dx < edgeMargin;
    bool onRightEdge = localPosition.dx > CHATWIDTH - edgeMargin;
    bool onTopEdge = localPosition.dy < edgeMargin;
    bool onBottomEdge = localPosition.dy > CHATHEIGHT - edgeMargin;
    bool _isResizingHorizontal = true;
    bool _isResizingVertical = true;

    if (onLeftEdge && onTopEdge) {
      // Top-left corner
      cursor = SystemMouseCursors.resizeUpLeftDownRight;
    } else if (onRightEdge && onTopEdge) {
      // Top-right corner
      cursor = SystemMouseCursors.resizeUpRightDownLeft;
    } else if (onLeftEdge && onBottomEdge) {
      // Bottom-left corner
      cursor = SystemMouseCursors.resizeUpRightDownLeft;
    } else if (onRightEdge && onBottomEdge) {
      // Bottom-right corner
      cursor = SystemMouseCursors.resizeUpLeftDownRight;
    } else if (onLeftEdge || onRightEdge) {
      // Left or right edge
      cursor = SystemMouseCursors.resizeLeftRight;
      _isResizingVertical = false;
    } else if (onTopEdge || onBottomEdge) {
      // Top or bottom edge
      cursor = SystemMouseCursors.resizeUpDown;
      _isResizingHorizontal = false;
    }
    isResizingHorizontal = _isResizingHorizontal;
    isResizingVertical = _isResizingVertical;

    setState(() {
    }); // Update the cursor state
  }

  Widget _buildChat(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: themeNotifier.value == ThemeMode.light
                ? Colors.black.withOpacity(0.2)
                : Colors.white.withOpacity(0.2),
          ),
        ],
      ),
      width: CHATWIDTH,
      height: CHATHEIGHT,
      child: Column(
        children: [
          ChatTopBar(context),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: ListView.builder(
                itemCount: _messages.length,
                controller: _scrollController,
                itemBuilder: (context, index) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  decoration: BoxDecoration(
                      color:
                          ChatCommons.stringToColor(_messages[index].ownerId),
                      borderRadius: BorderRadius.circular(12),
                      gradient: _messages[index].isPrivate
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.teal[200]!
                                    .withOpacity(1.0),
                                Colors.lightBlue[200]!.withOpacity(
                                    0.7), // Midpoint color with adjusted opacity
                                Colors.blueGrey[300]!
                                    .withOpacity(0.5),
                              ],
                              stops: const [
                                0.0,
                                0.5,
                                1.0
                              ],
                              tileMode: TileMode
                                  .clamp,
                            )
                          : null),
                  child: Text(
                    _messages[index].messageContent,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: RawKeyboardListener(
                    focusNode: FocusNode(),
                    onKey: (RawKeyEvent event) {
                      if (event is RawKeyDownEvent) {
                        switch (event.logicalKey) {
                          case LogicalKeyboardKey.arrowUp:
                            ChatCommons.handleArrowUp(
                                controller, lastMessageIndex);
                            break;
                        }
                      }
                    },
                    child: TextField(
                      focusNode: _focusNode,
                      controller: controller,
                      onSubmitted: (_) => ChatCommons.sendInput(controller,
                          widget.gruppeId, _focusNode, lastMessageIndex),
                      decoration: InputDecoration(
                        //hintText: '...',
                        hoverColor: Theme.of(context).canvasColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).canvasColor, //Colors.grey[200],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    ChatCommons.sendInput(controller, widget.gruppeId,
                        _focusNode, lastMessageIndex);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget ChatTopBar(BuildContext context) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Chat"),
            IconButton(
                icon: const Icon(Icons.minimize),
                onPressed: () {
                  setState(() {
                    widget.isMinimized.value = true;
                  });
                } //context.findAncestorStateOfType<__ChatOverlayContentState>()?.minimizeChat(),
                ),
          ],
        );
  }

  Widget _buildMinimizedIcon(BuildContext context) {
    return SizedBox(
      height: MINIMIZEDICONSIZE / 2,
      width: MINIMIZEDICONSIZE / 2,
      child: GestureDetector(
        onTap: () => setState(() {
          widget.isMinimized.value = false;
        }),
        child: const CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Icon(Icons.chat),
        ),
      ),
    );
  }
}

class FrameClipper extends CustomClipper<Path> {
  final double borderWidth;

  FrameClipper({this.borderWidth = 5.0});

  @override
  Path getClip(Size size) {
    Path path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height)) // Outer rectangle (full container)
      ..addRect(Rect.fromLTWH(borderWidth, borderWidth, size.width - 2 * borderWidth, size.height - 2 * borderWidth)) // Inner rectangle (cut-out)
      ..fillType = PathFillType.evenOdd;

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
enum BoxSide {
  left,
  right,
  top,
  bottom,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  none,
}