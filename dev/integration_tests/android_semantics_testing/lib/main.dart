// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_driver/driver_extension.dart';

import 'src/tests/controls_page.dart';
import 'src/tests/text_field_page.dart';

void main() {
  timeDilation = 0.05; // remove animations.
  enableFlutterDriverExtension(handler: dataHandler);
  runApp(const TestApp());
}

const MethodChannel kSemanticsChannel = MethodChannel('semantics');

Future<String> dataHandler(String message) async {
  if (message.contains('getSemanticsNode')) {
    final Completer<String> completer = new Completer<String>();
    final int id = int.tryParse(message.split('#')[1]) ?? 0;
    Future<void> completeSemantics([Object _]) async {
      final dynamic result = await kSemanticsChannel.invokeMethod('getSemanticsNode', <String, dynamic>{
        'id': id,
      });
      completer.complete(json.encode(result));
    }
    if (SchedulerBinding.instance.hasScheduledFrame)
      SchedulerBinding.instance.addPostFrameCallback(completeSemantics);
    else
      completeSemantics();
    return completer.future;
  }
  throw new UnimplementedError();
}

const List<String> routes = <String>[
  selectionControlsRoute,
  textFieldRoute,
];

class TestApp extends StatelessWidget {
  const TestApp();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      routes: <String, WidgetBuilder>{
        selectionControlsRoute: (BuildContext context) => new SelectionControlsPage(),
        textFieldRoute: (BuildContext context) => new TextFieldPage(),
      },
      home: new Builder(
        builder: (BuildContext context) {
          return new Scaffold(
            body: new ListView(
              children: routes.map((String value) {
                return new MaterialButton(
                  child: new Text(value),
                  onPressed: () {
                    Navigator.of(context).pushNamed(value);
                  },
                );
              }).toList(),
            ),
          );
        }
      ),
    );
  }
}
