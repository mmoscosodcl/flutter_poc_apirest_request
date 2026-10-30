import 'package:flutter/material.dart';
import '../../models/api_log.dart';
import '../../state/network_log_controller.dart';
import 'json_viewer.dart';
import 'status_badge.dart';

class NetworkConsoleSheet extends StatelessWidget {
  final NetworkLogController logController;

  const NetworkConsoleSheet({
    super.key,
    required this.logController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: logController,
      builder: (context, _) {
        if (!logController.showConsole) {
          return const SizedBox.shrink();
        }

        final logs = logController.logs;
        final selectedLog = logController.selectedLog;

        return Material(
          color: Theme.of(context).colorScheme.surface,
          elevation: 8,
          child: Container(
            height: 380,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header bar with overflow protection
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.terminal_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Live Network Inspector',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      if (logs.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                          tooltip: 'Clear Logs',
                          onPressed: logController.clearLogs,
                        ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        tooltip: 'Hide Network Console',
                        onPressed: logController.toggleConsole,
                      ),
                    ],
                  ),
                ),

                // Request tabs / selector
                if (logs.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No HTTP requests captured yet.\nTrigger a request or select a preset above.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else ...[
                  // Horizontal list of requests
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      scrollDirection: Axis.horizontal,
                      itemCount: logs.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final item = logs[index];
                        final isSelected = item.id == selectedLog?.id;
                        final uri = Uri.tryParse(item.url);
                        final path = uri?.path.isNotEmpty == true ? uri!.path : item.url;

                        return ChoiceChip(
                          selected: isSelected,
                          onSelected: (_) => logController.selectLog(item),
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.method,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 6),
                              StatusBadge(
                                statusCode: item.statusCode,
                                statusPhrase: item.statusPhrase,
                                isLoading: item.isLoading,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                path,
                                style: const TextStyle(fontSize: 11),
                              ),
                              if (item.durationMs != null) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '${item.durationMs}ms',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),

                  // Selected request details
                  if (selectedLog != null)
                    Expanded(
                      child: _SelectedLogDetail(log: selectedLog),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SelectedLogDetail extends StatelessWidget {
  final ApiLog log;

  const _SelectedLogDetail({required this.log});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Top status & duration row
        Row(
          children: [
            StatusBadge(
              statusCode: log.statusCode,
              statusPhrase: log.statusPhrase,
              isLoading: log.isLoading,
            ),
            const SizedBox(width: 10),
            if (log.durationMs != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 14, color: Colors.blueGrey),
                    const SizedBox(width: 4),
                    Text(
                      '${log.durationMs} ms latency',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            Text(
              '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}:${log.timestamp.second.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Educational Explanation Box
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: log.isSuccess
                ? Colors.green.shade50
                : log.isClientError
                    ? Colors.amber.shade50
                    : Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: log.isSuccess
                  ? Colors.green.shade200
                  : log.isClientError
                      ? Colors.amber.shade300
                      : Colors.red.shade200,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                log.isSuccess
                    ? Icons.info_outline
                    : Icons.error_outline,
                size: 18,
                color: log.isSuccess
                    ? Colors.green.shade800
                    : log.isClientError
                        ? Colors.amber.shade900
                        : Colors.red.shade900,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  log.explanation,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: log.isSuccess
                        ? Colors.green.shade900
                        : log.isClientError
                            ? Colors.amber.shade900
                            : Colors.red.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // URL tile
        Text(
          'Target URL:',
          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SelectableText(
          log.url,
          style: const TextStyle(fontSize: 12, color: Colors.blue, fontFamily: 'monospace'),
        ),
        const SizedBox(height: 8),

        // Request Headers wrapped in Material to prevent DecoratedBox splash assertion
        Material(
          type: MaterialType.transparency,
          child: ExpansionTile(
            shape: const Border(),
            collapsedShape: const Border(),
            initiallyExpanded: false,
            tilePadding: EdgeInsets.zero,
            title: Text(
              'Request Headers (${log.requestHeaders.length})',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: log.requestHeaders.entries.map((e) {
                    return Text(
                      '${e.key}: ${e.key.toLowerCase().contains("authorization") ? (e.value.length > 20 ? "${e.value.substring(0, 15)}..." : e.value) : e.value}',
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Response Headers wrapped in Material
        if (log.responseHeaders != null && log.responseHeaders!.isNotEmpty)
          Material(
            type: MaterialType.transparency,
            child: ExpansionTile(
              shape: const Border(),
              collapsedShape: const Border(),
              initiallyExpanded: false,
              tilePadding: EdgeInsets.zero,
              title: Text(
                'Response Headers (${log.responseHeaders!.length})',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: log.responseHeaders!.entries.map((e) {
                      final isRateLimit = e.key.toLowerCase().contains('ratelimit');
                      return Text(
                        '${e.key}: ${e.value}',
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          fontWeight: isRateLimit ? FontWeight.bold : FontWeight.normal,
                          color: isRateLimit ? Colors.deepPurple : Colors.black87,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 8),

        // Response Body
        if (log.responseBody != null)
          JsonViewer(
            jsonString: log.formattedResponseBody,
            title: 'Response Body (HTTP ${log.statusCode ?? 'unknown'})',
          ),
      ],
    );
  }
}
