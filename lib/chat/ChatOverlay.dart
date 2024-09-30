import 'dart:async';
import 'dart:math';

import 'package:dsagruppen/chat/ChatCommons.dart';
import 'package:dsagruppen/chat/ChatMessage.dart';
import 'package:dsagruppen/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'ChatMessageRepository.dart';
import 'SpeechButtonWidget.dart';

double CHATHEIGHT = 400;
double CHATWIDTH = 300;
double MINIMIZEDICONSIZE = 54;

class ChatOverlay with WidgetsBindingObserver {
  final Stream<ChatMessage> messageStream;
  late OverlayEntry overlayEntry;
  ValueNotifier<bool> isVisible = ValueNotifier(false);
  ValueNotifier<bool> isMinimized = ValueNotifier(true);
  String gruppeId;
  static ValueNotifier<Offset> offset = ValueNotifier(Offset(16, 16));

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
    offset.value = Offset(
        16, size.height - widgetIconSize.height); //todo set icon height instead
    overlayEntry = OverlayLayer(size);
    isVisible.addListener(switchOverlay);
  }

  OverlayEntry OverlayLayer(Size size) {
    isMinimized.addListener(() => recalcPosition());
    return OverlayEntry(builder: (context) {
      return ValueListenableBuilder(
          valueListenable: offset,
          builder: (context, value, child) {
            return Positioned(
              left: offset.value.dx,
              top: offset.value.dy,
              child: ChatOverlayContent(
                gruppeId: gruppeId,
                stream: messageStream,
                isMinimized: isMinimized,
              ),
            );
          });
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

      double newY = offset.value.dy - MINIMIZEDICONSIZE + CHATHEIGHT;

      newY = max(0, newY);
      newY = min(size.height - CHATHEIGHT, newY);

      offset.value = Offset(offset.value.dx, newY);
      overlayEntry.remove();
      overlayEntry = OverlayLayer(MediaQuery.of(context).size);
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
      offset.value = Offset(16, MediaQuery.sizeOf(context).height - 54);
      overlayEntry = OverlayLayer(MediaQuery.of(context).size);
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
  final ValueNotifier<bool> isMinimized;

  const ChatOverlayContent(
      {super.key,
        required this.stream,
        required this.gruppeId,
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
  BoxSide currentSide = BoxSide.none;
  var cursor = SystemMouseCursors.basic;
  final mouseBorderSize = 10.0;

  @override
  void initState() {
    super.initState();
    var oldMessages =
    getIt<ChatMessageRepository>().getMessages(widget.gruppeId);
    if (oldMessages != null) {
      _messages.addAll(oldMessages);
      ChatCommons.scrollToBottom(
          _scrollController, const Duration(milliseconds: 150));
    }
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

      double newWidth = CHATWIDTH;
      double newHeight = CHATHEIGHT;
      Offset newOffset = ChatOverlay.offset.value;

      // Determine resizing and position adjustments based on the side or corner
      switch (currentSide) {
        case BoxSide.right:
          newWidth += delta.dx;
          break;
        case BoxSide.left:
          newWidth -= delta.dx;
          newOffset = Offset(newOffset.dx + delta.dx, newOffset.dy);
          print(newOffset.dx);
          break;
        case BoxSide.bottom:
          newHeight += delta.dy;
          break;
        case BoxSide.top:
          newHeight -= delta.dy;
          newOffset = Offset(newOffset.dx, newOffset.dy + delta.dy);
          break;
        case BoxSide.topLeft:
          newWidth -= delta.dx;
          newHeight -= delta.dy;
          newOffset =
              Offset(newOffset.dx + delta.dx, newOffset.dy + delta.dy);
          break;
        case BoxSide.topRight:
          newWidth += delta.dx;
          newHeight -= delta.dy;
          newOffset = Offset(newOffset.dx, newOffset.dy + delta.dy);
          break;
        case BoxSide.bottomLeft:
          newWidth -= delta.dx;
          newHeight += delta.dy;
          newOffset = Offset(newOffset.dx + delta.dx, newOffset.dy);
          break;
        case BoxSide.bottomRight:
          newWidth += delta.dx;
          newHeight += delta.dy;
          break;
        default:
          break;
      }

      // Enforce minimum and maximum dimensions
      CHATWIDTH = max(
          minWidth, min(newWidth, screenSize.width - newOffset.dx));
      CHATHEIGHT = max(
          minHeight, min(newHeight, screenSize.height - newOffset.dy));
      ChatOverlay.offset.value = newOffset;
      // Update the offset if the chat overlay was resized from the left or top
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget currentChatState = widget.isMinimized.value == true
        ? _buildMinimizedIcon(context)
        : _buildChat(context);
    final chatRectWrapper = widget.isMinimized.value == true
        ? const SizedBox.shrink()
        : ClipPath(
      clipper: FrameClipper(borderWidth: mouseBorderSize),
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
            _updateSize(details.delta, context);
          },
          child: Container(
            height: CHATHEIGHT,
            width: CHATWIDTH,
            color: Colors.transparent, // Color of the frame
          ),
        ),
      ),
    );

    return Stack(
      children: [
        currentChatState, // Removed Draggable from here
        chatRectWrapper
      ],
    );
  }

  void _updateCursorOnHover(PointerHoverEvent event) {
    final edgeMargin = mouseBorderSize;
    final localPosition = event.localPosition;

    bool onLeftEdge = localPosition.dx < edgeMargin;
    bool onRightEdge = localPosition.dx > CHATWIDTH - edgeMargin;
    bool onTopEdge = localPosition.dy < edgeMargin;
    bool onBottomEdge = localPosition.dy > CHATHEIGHT - edgeMargin;

    if (onLeftEdge && onTopEdge) {
      // Top-left corner
      cursor = SystemMouseCursors.resizeUpLeftDownRight;
      currentSide = BoxSide.topLeft;
    } else if (onRightEdge && onTopEdge) {
      // Top-right corner
      cursor = SystemMouseCursors.resizeUpRightDownLeft;
      currentSide = BoxSide.topRight;
    } else if (onLeftEdge && onBottomEdge) {
      // Bottom-left corner
      cursor = SystemMouseCursors.resizeUpRightDownLeft;
      currentSide = BoxSide.bottomLeft;
    } else if (onRightEdge && onBottomEdge) {
      // Bottom-right corner
      cursor = SystemMouseCursors.resizeUpLeftDownRight;
      currentSide = BoxSide.bottomRight;
    } else if (onLeftEdge) {
      cursor = SystemMouseCursors.resizeLeftRight;
      currentSide = BoxSide.left;
    } else if (onRightEdge) {
      cursor = SystemMouseCursors.resizeLeftRight;
      currentSide = BoxSide.right;
    } else if (onTopEdge) {
      cursor = SystemMouseCursors.resizeUpDown;
      currentSide = BoxSide.top;
    } else if (onBottomEdge) {
      cursor = SystemMouseCursors.resizeUpDown;
      currentSide = BoxSide.bottom;
    } else {
      cursor = SystemMouseCursors.basic;
      currentSide = BoxSide.none;
    }

    setState(() {
      // Update the cursor state
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
          // Wrap ChatTopBar with GestureDetector for dragging
          GestureDetector(
            onPanUpdate: (details) {
              // Update the overlay's position
              ChatOverlay.offset.value += details.delta;
              // Mark the overlay as needing to rebuild to reflect the new position
              context.findAncestorStateOfType<ChatOverlayContentState>()?.setState(() {
              });

            },
            child: ChatTopBar(context),
          ),
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
                          Colors.teal[200]!.withOpacity(1.0),
                          Colors.lightBlue[200]!.withOpacity(0.7),
                          Colors.blueGrey[300]!.withOpacity(0.5),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        tileMode: TileMode.clamp,
                      )
                          : null),
                  child: SelectableText(
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
                SpeechButtonWidget(
                  textController: controller,
                ),
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
    final theme = Theme.of(context); // Get the current theme

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.8),
            theme.colorScheme.primaryContainer.withOpacity(0.8),
          ], // Use primary colors from theme
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4), // Subtle shadow for depth
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Chat",
            style: theme.textTheme.titleMedium!.copyWith(
              color: theme.colorScheme.onPrimary, // Adapt text color to theme
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.minimize, color: theme.colorScheme.onPrimary),
            onPressed: () {
              setState(() {
                widget.isMinimized.value = true;
              });
            },
          ),
        ],
      ),
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
      ..addRect(
          Rect.fromLTWH(0, 0, size.width, size.height)) // Outer rectangle
      ..addRect(Rect.fromLTWH(borderWidth, borderWidth,
          size.width - 2 * borderWidth, size.height - 2 * borderWidth)) // Inner rectangle
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
