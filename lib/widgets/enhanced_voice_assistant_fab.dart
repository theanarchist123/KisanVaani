import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_voice_assistant_provider.dart';

class EnhancedVoiceAssistantFAB extends StatelessWidget {
  const EnhancedVoiceAssistantFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedVoiceAssistantProvider>(
      builder: (context, provider, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mode Switch Button
            FloatingActionButton.small(
              onPressed: () => _showModeSelector(context, provider),
              backgroundColor: Colors.blue.shade100,
              heroTag: "mode_switch",
              child: Icon(
                provider.currentMode == VoiceAssistantMode.vapi 
                  ? Icons.cloud 
                  : Icons.phone_android,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 8),
            
            // Main Voice Button
            FloatingActionButton(
              onPressed: provider.isProcessing 
                ? null 
                : () => _handleVoiceAction(provider),
              backgroundColor: _getButtonColor(provider),
              heroTag: "voice_main",
              child: _getButtonIcon(provider),
            ),
            
            // Status Indicator
            if (provider.isProcessing)
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: Text(
                  'Processing...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Color _getButtonColor(EnhancedVoiceAssistantProvider provider) {
    if (provider.isProcessing) return Colors.orange;
    if (provider.isListening) return Colors.red;
    if (provider.isSpeaking) return Colors.blue;
    
    // Mode-specific colors
    if (provider.currentMode == VoiceAssistantMode.vapi) {
      return provider.vapiConnected ? Colors.green : Colors.grey;
    } else {
      return provider.ragBackendHealthy ? Colors.green : Colors.orange;
    }
  }

  Widget _getButtonIcon(EnhancedVoiceAssistantProvider provider) {
    if (provider.isProcessing) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      );
    }
    
    if (provider.isListening) {
      return const Icon(Icons.mic, color: Colors.white);
    }
    
    if (provider.isSpeaking) {
      return const Icon(Icons.volume_up, color: Colors.white);
    }
    
    return Icon(
      provider.currentMode == VoiceAssistantMode.vapi 
        ? Icons.assistant 
        : Icons.mic_none,
      color: Colors.white,
    );
  }

  Future<void> _handleVoiceAction(EnhancedVoiceAssistantProvider provider) async {
    if (provider.isListening) {
      await provider.stopListening();
    } else if (provider.isSpeaking) {
      await provider.stopSpeaking();
    } else {
      await provider.startListening();
    }
  }

  void _showModeSelector(BuildContext context, EnhancedVoiceAssistantProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ModeSelector(provider: provider),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final EnhancedVoiceAssistantProvider provider;

  const _ModeSelector({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Voice Assistant Mode',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          
          // Local RAG Mode
          _buildModeOption(
            context,
            mode: VoiceAssistantMode.local,
            title: 'Local RAG Mode',
            subtitle: 'Speech-to-text + RAG backend answers',
            icon: Icons.phone_android,
            isHealthy: provider.ragBackendHealthy,
            statusText: provider.ragBackendHealthy 
              ? 'RAG Backend Connected' 
              : 'RAG Backend Offline',
          ),
          
          const SizedBox(height: 16),
          
          // Vapi Mode
          _buildModeOption(
            context,
            mode: VoiceAssistantMode.vapi,
            title: 'Vapi Mode',
            subtitle: 'Full speech-to-speech conversation',
            icon: Icons.cloud,
            isHealthy: provider.vapiConnected,
            statusText: provider.vapiConnected 
              ? 'Vapi Connected' 
              : 'Vapi Disconnected',
          ),
          
          const SizedBox(height: 20),
          
          // System Status
          _buildSystemStatus(),
          
          const SizedBox(height: 20),
          
          // Refresh Button
          ElevatedButton.icon(
            onPressed: () async {
              await provider.refreshServices();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Services'),
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption(
    BuildContext context, {
    required VoiceAssistantMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isHealthy,
    required String statusText,
  }) {
    final isSelected = provider.currentMode == mode;
    
    return Card(
      color: isSelected ? Colors.green.shade50 : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: isHealthy ? Colors.green : Colors.red,
          size: 32,
        ),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 4),
            Text(
              statusText,
              style: TextStyle(
                color: isHealthy ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: isSelected 
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
        onTap: () async {
          await provider.switchMode(mode);
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildSystemStatus() {
    final status = provider.getSystemStatus();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Status',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            ...status.entries.map((entry) => _buildStatusRow(
              entry.key.replaceAll('_', ' ').toUpperCase(),
              entry.value.toString(),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: value.contains('true') || value.contains('healthy') || value.contains('connected')
                ? Colors.green
                : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
