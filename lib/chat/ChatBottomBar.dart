import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../globals.dart';
import 'ChatCommons.dart';
import 'ChatMessage.dart';
import 'ChatMessageRepository.dart';
import 'ExpandArrowContainer.dart';

class ChatBottomBar extends StatefulWidget {
  const ChatBottomBar({
    super.key,required this.stream, required this.gruppeId, this.callBack,
  });

  final String gruppeId;
  final Stream<ChatMessage> stream;
  final Function? callBack;

  @override
  State<ChatBottomBar> createState() => _ChatBottomBarState();
}

class _ChatBottomBarState extends State<ChatBottomBar> with SingleTickerProviderStateMixin {
  StreamSubscription<ChatMessage>? _streamSubscription;
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  ValueNotifier<int> lastMessageIndex = ValueNotifier(-1);
  final FocusNode _focusNode = FocusNode();
  TextEditingController controller = TextEditingController();
  late AnimationController animationController;
  final chatStyle = const TextStyle(fontSize: 10, color: Colors.black);
  final animationDuration = const Duration(milliseconds: 150);
  bool isInit = false;

  @override
  void initState() {
    super.initState();
    var oldMessages = getIt<ChatMessageRepository>().getMessages(widget.gruppeId);
    if(oldMessages != null){
      _messages.addAll(oldMessages);
      ChatCommons.scrollToBottom(_scrollController, animationDuration);
    }
    _streamSubscription = widget.stream.listen((message) {
      setState(() {
        _messages.add(message);
      });
      ChatCommons.scrollToBottomAnimated(_scrollController, animationDuration);
    });
    if(isChatVisible.value == true){
      isInit = true;
    }
    animationController = AnimationController(
      duration: animationDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var maxChat = SizedBox(
      height: MediaQuery.of(context).size.height * 0.2,
      child: Column(
        children: [
          InkWell(
            onTap: (){
              animationController.reverse().then((value) {
                widget.callBack?.call();
                isChatVisible.value = false;
              });
            },
            child: const ExpandArrowContainer(isExpanded: true),
          ),
          const Divider(height: 0.5, color: Colors.grey),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              thickness: 6.0, // Set the thickness of the scrollbar
              radius: const Radius.circular(10), // Set the radius of the scrollbar
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0.5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                      decoration: BoxDecoration(
                          color: ChatCommons.stringToColor(_messages[index].ownerId),
                          borderRadius: BorderRadius.circular(8),
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
                      child:
                      SelectableText(
                        _messages[index].messageContent,
                        style: chatStyle,
                        textAlign: TextAlign.left,
                      )
                    ),
                  );
                },
              ),
            ),
          ),
          //const Divider(height: 0.5, color: Colors.grey),
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              height: 24,
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
                        maxLines: 1,
                        focusNode: _focusNode,
                        controller: controller,
                        onSubmitted: (_) => ChatCommons.sendInput(controller, widget.gruppeId, _focusNode, lastMessageIndex),
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          isDense: true,
                          fillColor: Colors.grey.withOpacity(0.1),
                          filled: true,
                          hintText: "Schreibe eine Nachricht...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: () {
                      ChatCommons.sendInput(controller, widget.gruppeId, _focusNode, lastMessageIndex);
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
    if(isInit && isChatVisible.value == true){
      isInit = false;
    }
    return ValueListenableBuilder(
      valueListenable: isChatVisible,
      builder: (context, isVisible, child) {
        return isVisible ?
        maxChat.animate(autoPlay: true, controller: animationController).slide(duration: isInit ? animationDuration : const Duration(milliseconds: 0), begin: const Offset(0, 1))
            : MinimizedChat();
      },
    );
  }

  Widget MinimizedChat(){
    return  InkWell(
      onTap: (){
        animationController.forward(from: 0.0);
        widget.callBack?.call();
        isChatVisible.value = true;
      },
      child: const ExpandArrowContainer(isExpanded: false),
    );
  }

}
