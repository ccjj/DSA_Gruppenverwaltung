import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatBar extends StatefulWidget {
  @override
  State<ChatBar> createState() => ChatBarState();
}

class ChatBarState extends State<ChatBar> with SingleTickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      scrollbarOrientation: ScrollbarOrientation.left,
      thumbVisibility: true,
      child: Animate(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.2,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: scrollController,
                  itemCount: 8,
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                      children: [
                        Card(
                          margin: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Chat message $index',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ),
                        Spacer()
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ).animate(autoPlay: true, controller: _controller).slide(duration: 300.ms, begin: const Offset(0, 1))
      ),
    );
  }
}
