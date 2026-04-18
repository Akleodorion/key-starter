import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

void main() => runApp(const MidiTestApp());

class MidiTestApp extends StatefulWidget {
  const MidiTestApp({super.key});
  @override
  State<MidiTestApp> createState() => _MidiTestAppState();
}

class _MidiTestAppState extends State<MidiTestApp> {
  final MidiCommand _midi = MidiCommand();
  List<MidiDevice> _devices = [];
  List<String> _log = [];

  @override
  void initState() {
    super.initState();
    _scanDevices();
    _listenToMidi();
  }

  Future<void> _scanDevices() async {
    final devices = await _midi.devices;
    setState(() => _devices = devices ?? []);
  }

  void _listenToMidi() {
    _midi.onMidiDataReceived?.listen((packet) {
      final d = packet.data;
      if (d.length < 3) return;

      final isNoteOn = (d[0] & 0xF0) == 0x90 && d[2] > 0;
      if (!isNoteOn) return;

      final pitch = d[1];
      final noteNames = ['C','C#','D','D#','E','F','F#','G','G#','A','A#','B'];
      final name = noteNames[pitch % 12];
      final octave = (pitch ~/ 12) - 1;

      setState(() {
        _log.insert(0, '🎹 $name$octave  (pitch: $pitch)');
        if (_log.length > 20) _log.removeLast();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('MIDI Test')),
        body: Column(
          children: [
            // Devices détectés
            Padding(
              padding: const EdgeInsets.all(16),
              child: _devices.isEmpty
                  ? const Text('Aucun device MIDI détecté',
                      style: TextStyle(color: Colors.red))
                  : Column(
                      children: _devices
                          .map((d) => ListTile(
                                leading: const Icon(Icons.piano, color: Colors.green),
                                title: Text(d.name),
                                subtitle: Text(d.id),
                                trailing: ElevatedButton(
                                  onPressed: () => _midi.connectToDevice(d),
                                  child: const Text('Connecter'),
                                ),
                              ))
                          .toList(),
                    ),
            ),

            const Divider(),

            // Log des notes reçues
            Expanded(
              child: _log.isEmpty
                  ? const Center(child: Text('Joue une note...'))
                  : ListView.builder(
                      itemCount: _log.length,
                      itemBuilder: (_, i) => ListTile(
                        title: Text(_log[i],
                            style: const TextStyle(fontFamily: 'monospace')),
                      ),
                    ),
            ),

            // Bouton refresh
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton.icon(
                onPressed: _scanDevices,
                icon: const Icon(Icons.refresh),
                label: const Text('Scanner les devices'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _midi.dispose();
    super.dispose();
  }
}