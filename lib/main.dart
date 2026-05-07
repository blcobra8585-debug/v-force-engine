import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

void main() => runApp(MaterialApp(
  theme: ThemeData.dark(),
  debugShowCheckedModeBanner: false,
  home: VForceHome(),
));

class VForceHome extends StatefulWidget {
  @override
  _VForceHomeState createState() => _VForceHomeState();
}

class _VForceHomeState extends State<VForceHome> {
  final record = AudioRecorder();
  final player = AudioPlayer();
  bool isRecording = false;
  String apiKey = "sk_d3e04961bb854f814161080ba80bddc2"; // Tera Fake Account Key

  void toggleRecording() async {
    if (isRecording) {
      final path = await record.stop();
      setState(() => isRecording = false);
      if (path != null) convertAndPlay(path);
    } else {
      if (await record.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/input.m4a';
        await record.start(const RecordConfig(), path: path);
        setState(() => isRecording = true);
      }
    }
  }

  Future<void> convertAndPlay(String inputPath) async {
    // Bella Voice ID (Realistic Female)
    String voiceId = "EXAVITQu4vr4xnNLhMaY"; 
    var request = http.MultipartRequest('POST', Uri.parse('https://api.elevenlabs.io/v1/speech-to-speech/$voiceId'));
    request.headers.addAll({'xi-api-key': apiKey});
    request.files.add(await http.MultipartFile.fromPath('audio', inputPath));
    
    request.fields['model_id'] = 'eleven_turbo_v2_5';
    request.fields['voice_settings'] = jsonEncode({'stability': 0.4, 'similarity_boost': 0.8});

    var response = await request.send();
    if (response.statusCode == 200) {
      final bytes = await response.stream.toBytes();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/output.mp3');
      await file.writeAsBytes(bytes);
      await player.play(DeviceFileSource(file.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("V-FORCE ENGINE", style: TextStyle(color: Colors.cyanAccent, letterSpacing: 8, fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 100),
            GestureDetector(
              onTap: toggleRecording,
              child: Container(
                height: 160, width: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: isRecording ? Colors.redAccent : Colors.cyanAccent.withOpacity(0.5), blurRadius: 40)],
                  border: Border.all(color: isRecording ? Colors.redAccent : Colors.cyanAccent, width: 3),
                ),
                child: Icon(isRecording ? Icons.stop : Icons.mic, color: Colors.white, size: 70),
              ),
            ),
            SizedBox(height: 50),
            Text(isRecording ? "RECORDING LIVE..." : "TAP TO START PRANK", style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}

