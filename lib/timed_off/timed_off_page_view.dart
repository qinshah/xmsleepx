import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xmsleepx/timed_off/sleep_timer.dart';

class TimedOffPageView extends StatefulWidget {
  const TimedOffPageView({super.key});

  @override
  State<TimedOffPageView> createState() => _TimedOffPageViewState();
}

class _TimedOffPageViewState extends State<TimedOffPageView> {
  final _sliderMin = 5.0;
  final _sliderMax = 100.0;
  int _minutes = 30;
  late final _textController = TextEditingController(text: _minutes.toString());
  bool _isExitApp = false; // false: 停止播放, true: 退出应用

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onSliderChanged(double value) {
    setState(() {
      _minutes = value.toInt();
      _textController.text = _minutes.toString();
    });
  }

  void _onTextChanged(String value) {
    final intValue = int.tryParse(value);
    if (intValue != null && intValue > 0) {
      setState(() {
        _minutes = intValue;
      });
    }
  }

  void _startTimer() {
    SleepTimer.i.set(
      duration: Duration(minutes: _minutes),
      isExit: _isExitApp,
    );
  }

  void _cancelTimer() {
    setState(() {
      SleepTimer.i.cancel();
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('定时关闭'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: ValueListenableBuilder(
        valueListenable: SleepTimer.i.timerNotifier,
        builder: (context, remainTime, child) {
          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: remainTime != null
                ? [
                    SizedBox(height: 100),
                    Card(
                      color: colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.timer,
                              size: 48,
                              color: colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '剩余时间',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDuration(remainTime),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '结束后将${_isExitApp ? "退出应用" : "停止播放"}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _cancelTimer,
                      icon: const Icon(Icons.stop),
                      label: const Text('取消定时'),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ]
                : [
                    Text(
                      '设置定时时长',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '滑动',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _sliderMin.toStringAsFixed(0),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Expanded(
                                  child: Slider(
                                    value: _minutes.toDouble().clamp(
                                      _sliderMin,
                                      _sliderMax,
                                    ),
                                    label: _minutes.toString(),
                                    min: _sliderMin,
                                    max: _sliderMax,
                                    divisions: (_sliderMax - _sliderMin) ~/ 5,
                                    onChanged: _onSliderChanged,
                                  ),
                                ),
                                Text(
                                  _sliderMax.toStringAsFixed(0),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '或输入',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _textController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: _onTextChanged,
                              decoration: InputDecoration(
                                labelText: '分钟数',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixText: '分钟',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 定时行为选择
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              '结束后：',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SegmentedButton<bool>(
                              segments: const [
                                ButtonSegment<bool>(
                                  value: false,
                                  label: Text('停止播放'),
                                  icon: Icon(Icons.stop),
                                ),
                                ButtonSegment<bool>(
                                  value: true,
                                  label: Text('退出应用'),
                                  icon: Icon(Icons.exit_to_app),
                                ),
                              ],
                              selected: {_isExitApp},
                              onSelectionChanged: (Set<bool> newSelection) {
                                setState(() {
                                  _isExitApp = newSelection.first;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _startTimer,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('开始定时'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
          );
        },
      ),
    );
  }
}
