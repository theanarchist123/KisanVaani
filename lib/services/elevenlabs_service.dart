import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ElevenLabsService {
  static const String _apiKey = 'sk_716561712b8edacf6ff1da8345d06c69020a8addaa3a8d71';
  static const String _voiceId = 'm5qndnI7u4OAdXhH0Mr5';
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  /// Convert text to speech using ElevenLabs API
  Future<bool> speakText(String text) async {
    try {
      print('ElevenLabs: Converting text to speech: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
      
      // Prepare the request
      final url = Uri.parse('$_baseUrl/text-to-speech/$_voiceId');
      
      final requestBody = {
        'text': text,
        'model_id': 'eleven_multilingual_v2',
        'voice_settings': {
          'stability': 0.5,
          'similarity_boost': 0.75,
          'style': 0.0,
          'use_speaker_boost': true
        }
      };
      
      print('ElevenLabs: Making API request...');
      
      // Make the API call
      final response = await http.post(
        url,
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': _apiKey,
        },
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 30));
      
      print('ElevenLabs: Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        // Save audio to temporary file and play it
        final audioBytes = response.bodyBytes;
        await _playAudioFromBytes(audioBytes);
        return true;
      } else {
        print('ElevenLabs: Error ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      print('ElevenLabs: Error converting text to speech: $e');
      return false;
    }
  }
  
  /// Play audio from bytes
  Future<void> _playAudioFromBytes(Uint8List audioBytes) async {
    try {
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final audioFile = File(path.join(tempDir.path, 'elevenlabs_audio_${DateTime.now().millisecondsSinceEpoch}.mp3'));
      
      // Write audio bytes to file
      await audioFile.writeAsBytes(audioBytes);
      
      print('ElevenLabs: Playing audio file: ${audioFile.path}');
      
      // Play the audio file
      await _audioPlayer.play(DeviceFileSource(audioFile.path));
      
      // Clean up the temporary file after a delay
      Future.delayed(const Duration(minutes: 1), () {
        if (audioFile.existsSync()) {
          audioFile.deleteSync();
        }
      });
    } catch (e) {
      print('ElevenLabs: Error playing audio: $e');
      rethrow;
    }
  }
  
  /// Stop current audio playback
  Future<void> stopSpeaking() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('ElevenLabs: Error stopping audio: $e');
    }
  }
  
  /// Check if currently speaking
  Future<bool> get isSpeaking async {
    try {
      final state = await _audioPlayer.getDuration();
      return state != null;
    } catch (e) {
      return false;
    }
  }
  
  /// Dispose of the audio player
  void dispose() {
    _audioPlayer.dispose();
  }
}
