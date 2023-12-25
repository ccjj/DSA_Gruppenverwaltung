import 'dart:async';
import 'dart:math';

import 'package:dsagruppen/chat/ChatCommons.dart';
import 'package:dsagruppen/chat/ChatMessage.dart';
import 'package:dsagruppen/globals.dart';
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
  Offset _offset = Offset(16, 16);

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

      // Calculate the new Y position
      double newY = _offset.dy - MINIMIZEDICONSIZE + CHATHEIGHT;

      // Constrain newY to the screen bounds
      newY = max(0, newY);
      newY = min(size.height - CHATHEIGHT, newY);

      // Update the offset
      _offset = Offset(_offset.dx, newY);
      overlayEntry.remove();
      // Rebuild the overlay with the new position
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

  @override
  Widget build(BuildContext context) {
    final Widget currentChatState = widget.isMinimized.value == true
        ? _buildMinimizedIcon(context)
        : _buildChat(context);

    return Draggable(
        feedback: currentChatState,
        childWhenDragging: SizedBox.shrink(),
        onDragEnd: widget.onDragEnd,
        child: currentChatState);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Chat"),
              IconButton(
                  icon: const Icon(Icons.minimize),
                  onPressed: () {
                    setState(() {
                      widget.isMinimized.value = true;
                    });
                  } //context.findAncestorStateOfType<__ChatOverlayContentState>()?.minimizeChat(),
                  ),
            ],
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
                                Colors.teal[200]!
                                    .withOpacity(1.0), // More opaque
                                Colors.lightBlue[200]!.withOpacity(
                                    0.7), // Midpoint color with adjusted opacity
                                Colors.blueGrey[300]!
                                    .withOpacity(0.5), // Less opaque
                              ],
                              stops: const [
                                0.0,
                                0.5,
                                1.0
                              ], // Adjust these values based on your preference
                              tileMode: TileMode
                                  .clamp, // Prevents repetition of the gradient
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
