import 'dart:async';

import 'package:dsagruppen/chat/ChatCommons.dart';
import 'package:dsagruppen/chat/ChatMessage.dart';
import 'package:dsagruppen/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatOverlay {
  final Stream<ChatMessage> messageStream;
  late OverlayEntry overlayEntry;
  ValueNotifier isVisible;
  String gruppeId;
  Offset offset = const Offset(16, 16);

  ChatOverlay({required this.messageStream, required this.isVisible, required this.gruppeId}) {
    var context = navigatorKey.currentContext!;
    offset = Offset(16, MediaQuery.of(context).size.height - 54);
    overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: offset.dx,
          top: offset.dy,
          child: _ChatOverlayContent(
            gruppeId: gruppeId,
            stream: messageStream,
            onDragEnd: (details) {
              offset = details.offset;
              overlayEntry.markNeedsBuild(); // Update the overlay position
            },
          ),
        ));
    isVisible.addListener(switchOverlay);
  }

  void hideOverlay(){
    if(isVisible.value == false){
      overlayEntry.remove();
    }
  }

  void switchOverlay(){
    if (isVisible.value == true) {
      BuildContext context = navigatorKey.currentContext!;
      Overlay.of(context).insert(overlayEntry);
    } else {
      overlayEntry.remove();
    }
  }

  void dispose() {
    isVisible.removeListener(switchOverlay);
  }

}

class _ChatOverlayContent extends StatefulWidget {
  final Stream<ChatMessage> stream;
  final String gruppeId;
  final Function(DraggableDetails) onDragEnd;

  const _ChatOverlayContent({Key? key, required this.stream, required this.gruppeId, required this.onDragEnd}) : super(key: key);

  @override
  __ChatOverlayContentState createState() => __ChatOverlayContentState();
}

class __ChatOverlayContentState extends State<_ChatOverlayContent> {
  final List<ChatMessage> _messages = [];
  StreamSubscription<ChatMessage>? _streamSubscription;
  TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ValueNotifier<int> lastMessageIndex = ValueNotifier(-1);
  FocusNode _focusNode = FocusNode();
  ValueNotifier isMinimized = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _streamSubscription = widget.stream.listen((message) {
      setState(() {
        _messages.add(message);
       ChatCommons.scrollToBottom(_scrollController, const Duration(milliseconds: 150));
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
    return Draggable(
      feedback: widget,
      childWhenDragging: Container(), // Display nothing when dragging
      onDragEnd: widget.onDragEnd,
      child: ValueListenableBuilder(valueListenable: isMinimized, builder:
          (context, value, child) {
        return isMinimized.value == true ? _buildMinimizedIcon(context) : Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: themeNotifier.value == ThemeMode.light ?  Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.2),
              ),
            ],
          ),
          width: 300,
          height: 400,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Chat"),
                  IconButton(
                      icon: const Icon(Icons.minimize),
                      onPressed: () {
                        isMinimized.value = true;
                      }//context.findAncestorStateOfType<__ChatOverlayContentState>()?.minimizeChat(),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      decoration: BoxDecoration(
                          color: ChatCommons.stringToColor(_messages[index].ownerId),
                          borderRadius: BorderRadius.circular(12),
                          gradient: _messages[index].isPrivate ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.teal[200]!.withOpacity(1.0), // More opaque
                              Colors.lightBlue[200]!.withOpacity(0.7), // Midpoint color with adjusted opacity
                              Colors.blueGrey[300]!.withOpacity(0.5), // Less opaque
                            ],
                            stops: const [0.0, 0.5, 1.0], // Adjust these values based on your preference
                            tileMode: TileMode.clamp, // Prevents repetition of the gradient
                          )
                              : null

                      ),
                      child: Text(
                        _messages[index].messageContent,
                        style: const TextStyle(color: Colors.white),
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
                          if(event is RawKeyDownEvent){
                            switch (event.logicalKey){
                              case LogicalKeyboardKey.arrowUp:
                                ChatCommons.handleArrowUp(controller, lastMessageIndex);
                                break;
                            }
                          }
                        },
                        child: TextField(
                          focusNode: _focusNode,
                          controller: controller,
                          onSubmitted: (_) => ChatCommons.sendInput(controller, widget.gruppeId, _focusNode, lastMessageIndex),
                          decoration: InputDecoration(
                            //hintText: '...',
                            hoverColor: Theme.of(context).canvasColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).canvasColor,//Colors.grey[200],

                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                       ChatCommons.sendInput(controller, widget.gruppeId, _focusNode, lastMessageIndex);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ) ;
      },
      ),
    );
  }

  Widget _buildMinimizedIcon(BuildContext context) {
    return GestureDetector(
      onTap: () => isMinimized.value = false,
      child: const CircleAvatar(
        backgroundColor: Colors.transparent,
        child: Icon(Icons.chat),
      ),
    );
  }

}

