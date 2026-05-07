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
  home: VForceEngine(),
));

class VForceEngine extends StatefulWidget {
  @override
  _VForceEngineState createState() => _VForceEngineState();
}

class _VForceEngineState extends State<VForceEngine> {
  final record = AudioRecorder();
  final player = AudioPlayer();
  bool isRecording = false;
  bool isProcessing = false;
  String apiKey = "sk_d3e04961bb854f814161080ba80bddc2"; // Tera ElevenLabs Key

  void toggleRecording() async {
    if (isRecording) {
      final path = await record.stop();
      setState(() { isRecording = false; isProcessing = true; });
      if (path != null) convertAndPlay(path);
    } else {
      if (await record.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/myvoice.m4a';
        await record.start(const RecordConfig(), path: path);
        setState(() => isRecording = true);
      }
    }
  }

  Future<void> convertAndPlay(String inputPath) async {
    String voiceId = "EXAVITQu4vr4xnNLhMaY"; // Bella (Realistic Female)
    try {
      var request = http.MultipartRequest('POST', Uri.parse('https://api.elevenlabs.io/v1/speech-to-speech/$voiceId'));
      request.headers.addAll({'xi-api-key': apiKey});
      request.files.add(await http.MultipartFile.fromPath('audio', inputPath));
      
      request.fields['model_id'] = 'eleven_turbo_v2_5';
      request.fields['voice_settings'] = jsonEncode({'stability': 0.35, 'similarity_boost': 0.85});

      var response = await request.send();
      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/output.mp3');
        await file.writeAsBytes(bytes);
        await player.play(DeviceFileSource(file.path));
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      body: Container(
        decoration: BoxDecoration(
          radialGradient: RadialGradient(
            colors: [Colors.cyanAccent.withOpacity(0.1), Colors.transparent],
            radius: 1.5,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("V-FORCE GHOST", style: TextStyle(color: Colors.cyanAccent, letterSpacing: 10, fontSize: 30, fontWeight: FontWeight.w900)),
              SizedBox(height: 80),
              GestureDetector(
                onTap: isProcessing ? null : toggleRecording,
                child: Container(
                  height: 180, width: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isRecording ? Colors.redAccent : Colors.cyanAccent.withOpacity(0.5), 
                        blurRadius: 50, 
                        spreadRadius: 2
                      )
                    ],
                    border: Border.all(color: isRecording ? Colors.redAccent : Colors.cyanAccent, width: 4),
                  ),
                  child: Center(
                    child: isProcessing 
                      ? CircularProgressIndicator(color: Colors.cyanAccent)
                      : Icon(isRecording ? Icons.stop_rounded : Icons.mic_none_rounded, color: Colors.white, size: 80),
                  ),
                ),
              ),
              SizedBox(height: 60),
              Text(
                isProcessing ? "AI VOICE CLONING..." : (isRecording ? "LISTENING..." : "HOLD TO PRANK"),
                style: TextStyle(color: Colors.white38, letterSpacing: 2, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
