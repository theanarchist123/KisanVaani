import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/smart_translation_provider.dart';

class SmartText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  
  const SmartText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  State<SmartText> createState() => _SmartTextState();
}

class _SmartTextState extends State<SmartText> {
  String? translatedText;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _translateText();
  }

  @override
  void didUpdateWidget(SmartText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _translateText();
    }
  }

  Future<void> _translateText() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
    });

    final provider = Provider.of<SmartTranslationProvider>(context, listen: false);
    final translated = await provider.t(widget.text);
    
    if (mounted) {
      setState(() {
        translatedText = translated;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SmartTranslationProvider>(
      builder: (context, provider, child) {
        // Re-translate when language changes
        if (provider.currentLanguage != 'en' && translatedText == null) {
          _translateText();
        }
        
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.style?.color ?? Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
                    ),
                  ),
                )
              : Text(
                  translatedText ?? widget.text,
                  style: widget.style,
                  textAlign: widget.textAlign,
                  maxLines: widget.maxLines,
                  overflow: widget.overflow,
                ),
        );
      },
    );
  }
}

// Extension for easy translation access
extension SmartTranslation on BuildContext {
  Future<String> translate(String text) async {
    return await Provider.of<SmartTranslationProvider>(this, listen: false).t(text);
  }
  
  String get currentLanguage {
    return Provider.of<SmartTranslationProvider>(this, listen: false).currentLanguage;
  }
}

// Helper widget for buttons with translation
class SmartButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Widget? icon;
  
  const SmartButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.style,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon!,
        label: SmartText(text),
        style: style,
      );
    }
    
    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: SmartText(text),
    );
  }
}
