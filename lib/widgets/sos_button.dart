import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:torch_light/torch_light.dart';
import 'package:audioplayers/audioplayers.dart';

class SosButton extends StatefulWidget {
  const SosButton({super.key});

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> {
  bool _isVibrating = false;
  Timer? _holdTimer;
  bool _isHolding = false;
  double _sliderPosition = 0.0;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _holdTimer?.cancel();
    _stopVibration();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startContinuousSOS() async {
    if (_isVibrating || !mounted) return;

    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('audio/emergency_alert.mp3'));
    } catch (e) {
      print("Error playing audio: $e");
    }

    bool? hasVibrator = await Vibration.hasVibrator();
    bool hasFlashlight = await _isFlashlightAvailable();
    if (hasVibrator != true || !hasFlashlight) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Device does not support required features.")),
        );
      }
      return;
    }

    setState(() {
      _isVibrating = true;
      _isHolding = false;
      _sliderPosition = 0.0;
    });

    _runSosCycle();
  }

  Future<void> _runSosCycle() async {
    if (!_isVibrating) return;

    // This is now a rapid, continuous flashing pattern.
    // Each pulse is 300ms ON, followed by a 300ms OFF pause.
    for (int i = 0; i < 9; i++) {
      if (!_isVibrating) break;
      await _pulse(const Duration(milliseconds: 300));
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (!_isVibrating) {
      _cleanUp();
      return;
    }

    // --- THIS IS THE CHANGE ---
    // The final delay has been removed to make the loop more continuous.
    // await Future.delayed(const Duration(milliseconds: 300));

    // After the pause, call this function again to start the next cycle.
    _runSosCycle();
  }

  Future<void> _pulse(Duration duration) async {
    if (!_isVibrating) return;
    await _turnOnFlashlight();
    Vibration.vibrate(duration: duration.inMilliseconds);
    await Future.delayed(duration);
    await _turnOffFlashlight();
  }

  Future<void> _stopVibration() async {
    await _audioPlayer.stop();
    if (mounted) {
      setState(() {
        _isVibrating = false;
      });
    }
    _cleanUp();
  }

  Future<void> _cleanUp() async {
    await Vibration.cancel();
    await _turnOffFlashlight();
  }

  Future<bool> _isFlashlightAvailable() async {
    try {
      return await TorchLight.isTorchAvailable();
    } on Exception catch (e) {
      print("Could not check for flashlight: $e");
      return false;
    }
  }

  Future<void> _turnOnFlashlight() async {
    try {
      await TorchLight.enableTorch();
    } on Exception catch (e) {
      print("Could not enable flashlight: $e");
    }
  }

  Future<void> _turnOffFlashlight() async {
    try {
      await TorchLight.disableTorch();
    } on Exception catch (e) {
      print("Could not disable flashlight: $e");
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (_isVibrating) return;
    setState(() {
      _isHolding = true;
    });
    _holdTimer = Timer(const Duration(seconds: 3), () {
      _startContinuousSOS();
    });
  }

  void _onTapUp(TapUpDetails details) {
    _holdTimer?.cancel();
    if (mounted) {
      setState(() {
        _isHolding = false;
      });
    }
  }

  Widget _buildActivateButton(ThemeData theme) {
    return GestureDetector(
      onDoubleTap: _startContinuousSOS,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      child: AnimatedScale(
        scale: _isHolding ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: FloatingActionButton.extended(
          onPressed: null,
          backgroundColor: theme.colorScheme.error,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.sos_rounded, size: 28),
          label: Text('EMERGENCY SOS',
              style: theme.textTheme.labelLarge
                  ?.copyWith(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildStopSlider(ThemeData theme) {
    const double sliderHeight = 60.0;
    const double sliderWidth = 250.0;
    const double thumbSize = 50.0;
    final double maxDrag = sliderWidth - thumbSize - 10;

    return Container(
      height: sliderHeight,
      width: sliderWidth,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          const Center(
            child: Text('SLIDE TO STOP',
                style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.2)),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            left: _sliderPosition + 5,
            top: (sliderHeight - thumbSize) / 2,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _sliderPosition =
                      (_sliderPosition + details.delta.dx).clamp(0.0, maxDrag);
                });
              },
              onHorizontalDragEnd: (details) {
                if (_sliderPosition > maxDrag * 0.75) {
                  _stopVibration();
                } else {
                  setState(() {
                    _sliderPosition = 0;
                  });
                }
              },
              child: Container(
                width: thumbSize,
                height: thumbSize,
                decoration: BoxDecoration(
                    color: theme.colorScheme.error, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 60,
      width: 250,
      child:
          _isVibrating ? _buildStopSlider(theme) : _buildActivateButton(theme),
    );
  }
}
