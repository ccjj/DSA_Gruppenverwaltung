import 'dart:math';

import 'package:flutter/material.dart';

import '../Held/HeldRepository.dart';
import '../globals.dart';
import 'MessageAmplifySubscriptionService.dart';
import 'PersonalChatMessageRepository.dart';

class ChatCommons {
  static void scrollToBottom(
      ScrollController scrollController, Duration animationDuration) {
    Future.delayed(animationDuration, () {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  static void scrollToBottomAnimated(
      ScrollController scrollController, Duration animationDuration) {
    Future.delayed(animationDuration, () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: animationDuration,
          curve: Curves.easeOut,
        );
      }
    });
  }

  static String parseInputAndRollDice(String input) {
    final regex = RegExp(r'^(?:/*roll )?(\d+)[dDwW](\d+)$');
    final match = regex.firstMatch(input);
    int numberOfDice = 1;
    int sidesOfDice = 1;

    if (match == null) {
      final regex2 = RegExp(r'^#(\d+)?[dDwW](\d+)$');
      final match2 = regex2.firstMatch(input);
      if(match2 == null){
        return input;
      } else {
        numberOfDice = int.tryParse(match2.group(1) ?? '1') ?? 1;
        sidesOfDice = int.parse(match2.group(2)!);
      }
    } else {
      numberOfDice = int.parse(match.group(1)!);
      sidesOfDice = int.parse(match.group(2)!);
    }

    Random random = Random();
    List<int> results = [];

    for (int i = 0; i < numberOfDice; i++) {
      results.add(random.nextInt(sidesOfDice) + 1);
    }

    return '${numberOfDice}w${sidesOfDice}: ' + results.join(' + ');
  }

  static void sendInput(TextEditingController controller, String gruppeId,
      FocusNode focusNode, ValueNotifier<int> lastMessageIndex) {
    if (controller.text.trim().isNotEmpty && gruppeId.isNotEmpty) {
      var held = getIt<HeldRepository>().getHeldByGruppeId(gruppeId);
      var msgNamePrefix = held != null ? "${held.name}: " : "${cu.name}: ";
      var msg = ChatCommons.parseInputAndRollDice(controller.text);
      getIt<PersonalChatMessageRepository>().add(controller.text);
      getIt<MessageAmplifySubscriptionService>()
          .createMessage(msgNamePrefix + msg, gruppeId, cu.uuid);
      controller.text = "";
      lastMessageIndex.value = -1;
      focusNode.requestFocus();
    }
  }

  static void handleArrowUp(
      TextEditingController controller, ValueNotifier<int> lastMessageIndex) {
    List<String> lastMessages =
        getIt<PersonalChatMessageRepository>().getMessages();
    if(lastMessages.isEmpty) return;
    if (lastMessageIndex.value < lastMessages.length - 1) {
      lastMessageIndex.value = lastMessageIndex.value + 1;
      controller.text = lastMessages[lastMessageIndex.value];
    } else {
      controller.text = "";
      lastMessageIndex.value = -1;
    }
  }

  static void handleArrowDown(
      TextEditingController controller, ValueNotifier<int> lastMessageIndex) {
    List<String> lastMessages =
    getIt<PersonalChatMessageRepository>().getMessages();

    if(lastMessages.isEmpty) return;

    if (lastMessageIndex.value > 0) {
      lastMessageIndex.value = lastMessageIndex.value - 1;
      controller.text = lastMessages[lastMessageIndex.value];
    } else {
      controller.text = "";
      lastMessageIndex.value = -1;
    }
  }

  static Color stringToColor(String inputString) {
    final int hash = inputString.hashCode;
    final int color =
        (0xFF << 24) | (hash & 0x00FFFFFF); // 0xFF for full opacity
    return Color(color);
  }
}
