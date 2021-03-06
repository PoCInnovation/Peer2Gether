// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webrtc_viewmodel.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$WebRtcViewModel on _WebRtcViewModelBase, Store {
  final _$offerConnectionAsyncAction =
      AsyncAction('_WebRtcViewModelBase.offerConnection');

  @override
  Future<void> offerConnection(
      String roomName, String userName, MessageHandler messageHandler) {
    return _$offerConnectionAsyncAction
        .run(() => super.offerConnection(roomName, userName, messageHandler));
  }

  final _$answerConnectionAsyncAction =
      AsyncAction('_WebRtcViewModelBase.answerConnection');

  @override
  Future<void> answerConnection(
    RTCSessionDescription offer,
    String roomName,
    String userName,
    MessageHandler messageHandler,
  ) {
    return _$answerConnectionAsyncAction.run(() =>
        super.answerConnection(offer, roomName, userName, messageHandler));
  }

  final _$acceptAnswerAsyncAction =
      AsyncAction('_WebRtcViewModelBase.acceptAnswer');

  @override
  Future<void> acceptAnswer(RTCSessionDescription answer) {
    return _$acceptAnswerAsyncAction.run(() => super.acceptAnswer(answer));
  }

  final _$sendMessageAsyncAction =
      AsyncAction('_WebRtcViewModelBase.sendMessage');

  @override
  Future<void> sendMessage(String message) {
    return _$sendMessageAsyncAction.run(() => super.sendMessage(message));
  }
}
