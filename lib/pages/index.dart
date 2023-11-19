import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import './call.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final _chanellController = TextEditingController();
  bool _validateError = false;
  ClientRoleType role = ClientRoleType.clientRoleBroadcaster;

  @override
  void dispose(){
    _chanellController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Walkie Talkie"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 40,),
              TextField(
                controller: _chanellController,
                decoration: InputDecoration(
                  errorText: (_validateError) ? "Channel name is mandatory" : null,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 1
                    )
                  ),
                  hintText: "Channel name"
                ),
              ),
              ElevatedButton(
                onPressed: onJoin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40)
                ),
                child: const Text("Join"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onJoin() async{
    setState(() {
      _chanellController.text.isEmpty ? _validateError = true : _validateError = false;
    });
    if(_chanellController.text.isNotEmpty){
      await _handleCameraAndMicPermission(Permission.camera);
      await _handleCameraAndMicPermission(Permission.microphone);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
            chanellName: _chanellController.text,
            role: ClientRoleType.clientRoleBroadcaster,
          )
        )
      );
    }
  }

  Future<void> _handleCameraAndMicPermission(Permission permission) async{
    final status = await permission.request();
    log(status.toString());
  }

}
