import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

class GodLevelEngine {
  final audioRecord = AudioRecorder();
  final audioPlayer = AudioPlayer();
  final String apiKey = "sk_d3e04961bb854f814161080ba80bddc2";

  // 1. Record Shuru Karo
  void startPrank() async {
    if (await audioRecord.hasPermission()) {
      final path = await getTemporaryDirectory();
      await audioRecord.start(const RecordConfig(), path: '${path.path}/input.m4a');
    }
  }

  // 2. Stop & Convert (ElevenLabs)
  void stopAndConvert() async {
    final path = await audioRecord.stop();
    if (path != null) {
      // Yahan ElevenLabs ki API call hogi (jo maine pehle code diya tha)
      // Conversion ke baad hum 'output.mp3' play karenge
      await audioPlayer.play(DeviceFileSource('path_to_output.mp3'));
    }
  }
}

