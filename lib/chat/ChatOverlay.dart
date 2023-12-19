import 'dart:async';
import 'dart:math';

import 'package:dsagruppen/chat/ChatMessage.dart';
import 'package:dsagruppen/chat/MessageAmplifyService.dart';
import 'package:dsagruppen/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'PersonalChatMessageRepository.dart';

class ChatOverlay {
  final Stream<ChatMessage> messageStream;
  late OverlayEntry overlayEntry;
  ValueNotifier isVisible;
  String gruppeId;
  Offset offset = Offset(16, 16); // Initial position

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
    print("DISPOSE");
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
  int lastMessageIndex = -1;
  FocusNode _focusNode = FocusNode();
  ValueNotifier isMinimized = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _streamSubscription = widget.stream.listen((message) {
      setState(() {
        _messages.add(message);
        Future.delayed(const Duration(milliseconds: 150), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
            );
          }
        });
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
                          color: stringToColor(_messages[index].ownerId),//Theme.of(context).primaryColor.withOpacity(0.85),//stringToColor(cu.uuid),//
                          borderRadius: BorderRadius.circular(12),
                          gradient: _messages[index].isPrivate ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.teal[200]!.withOpacity(1.0), // More opaque
                              Colors.lightBlue[200]!.withOpacity(0.7), // Midpoint color with adjusted opacity
                              Colors.blueGrey[300]!.withOpacity(0.5), // Less opaque
                            ],
                            stops: [0.0, 0.5, 1.0], // Adjust these values based on your preference
                            tileMode: TileMode.clamp, // Prevents repetition of the gradient
                          )
                              : null

                      ),
                      child: Text(
                        _messages[index].messageContent,
                        style: TextStyle(color: Colors.white),
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
                                _handleArrowUp();
                                break;
                            }

                          }
                        },
                        child: TextField(
                          focusNode: _focusNode,
                          controller: controller,
                          onSubmitted: (_) => _sendInput(),
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
                        _sendInput();
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
        child: Icon(Icons.chat),
        backgroundColor: Colors.transparent,
      ),
    );
  }

  void _sendInput() {
    if(controller.text.trim().isNotEmpty && widget.gruppeId.isNotEmpty){
      //TODO progress bar etc
      var msg = rollDice(controller.text);
      getIt<PersonalChatMessageRepository>().add(controller.text);
      getIt<MessageAmplifyService>().createMessage(msg, widget.gruppeId, cu.uuid);
      controller.text = "";
      lastMessageIndex = -1;
      _focusNode.requestFocus();
    }
  }

  String rollDice(String input) {
    final regex = RegExp(r'^/roll (\d+)[dDwW](\d+)$');
    final match = regex.firstMatch(input);

    if (match == null) {
      return input;
    }

    int numberOfDice = int.parse(match.group(1)!);
    int sidesOfDice = int.parse(match.group(2)!);
    Random random = Random();
    List<int> results = [];

    for (int i = 0; i < numberOfDice; i++) {
      results.add(random.nextInt(sidesOfDice) + 1);
    }

    return  '${numberOfDice}w${sidesOfDice}: '+ results.join(' + ');
  }

  void _handleArrowUp() {
    List<String> lastMessages = getIt<PersonalChatMessageRepository>().getMessages();
    if (lastMessages.isNotEmpty && lastMessageIndex < lastMessages.length - 1) {
      setState(() {
        lastMessageIndex++;
        controller.text = lastMessages[lastMessageIndex];
      });
    }
  }


}

Color stringToColor(String inputString) {
  final int hash = inputString.hashCode;
  final int color = (0xFF << 24) | (hash & 0x00FFFFFF); // 0xFF for full opacity
  return Color(color);
}