import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../../../theme/app_theme.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback onAttach;

  const MessageInput({
    super.key,
    required this.onSendMessage,
    required this.onAttach,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isComposing = _messageController.text.trim().isNotEmpty;
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      widget.onSendMessage(_messageController.text.trim());
      _messageController.clear();
      setState(() {
        _isComposing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.pureBlack.withValues(alpha: 0.8),
            AppTheme.darkGray,
          ],
        ),
        border: Border(
          top: BorderSide(
            color: AppTheme.toxicYellow.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
        child: Row(
          children: [
            // Кнопка прикрепления
            _buildAttachButton(),
            SizedBox(width: 8),
            
            // Поле ввода
            Expanded(child: _buildInputField()),
            SizedBox(width: 8),
            
            // Кнопка отправки
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.mediumGray.withValues(alpha: 0.4),
            AppTheme.mediumGray.withValues(alpha: 0.2),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.toxicYellow.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.onAttach,
          child: Icon(
            EvaIcons.attach2Outline,
            color: Colors.grey.shade400,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.mediumGray.withValues(alpha: 0.3),
            AppTheme.mediumGray.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _isComposing 
              ? AppTheme.toxicYellow.withValues(alpha: 0.5)
              : AppTheme.mediumGray.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: _isComposing
            ? [
                BoxShadow(
                  color: AppTheme.toxicYellow.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _messageController,
        focusNode: _focusNode,
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Напишите сообщение...',
          hintStyle: GoogleFonts.montserrat(
            color: Colors.grey.shade600,
            fontSize: 15,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          suffixIcon: _isComposing
              ? IconButton(
                  icon: Icon(
                    EvaIcons.closeCircle,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                  onPressed: () {
                    _messageController.clear();
                    setState(() {
                      _isComposing = false;
                    });
                  },
                )
              : null,
        ),
        maxLines: null,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => _sendMessage(),
        onChanged: (_) => _onTextChanged(),
      ),
    );
  }

  Widget _buildSendButton() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: _isComposing
            ? LinearGradient(
                colors: [
                  AppTheme.toxicYellow,
                  AppTheme.darkYellow,
                ],
              )
            : LinearGradient(
                colors: [
                  AppTheme.mediumGray.withValues(alpha: 0.4),
                  AppTheme.mediumGray.withValues(alpha: 0.2),
                ],
              ),
        shape: BoxShape.circle,
        border: Border.all(
          color: _isComposing
              ? AppTheme.toxicYellow.withValues(alpha: 0.5)
              : AppTheme.mediumGray.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: _isComposing
            ? [
                BoxShadow(
                  color: AppTheme.toxicYellow.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _isComposing ? _sendMessage : null,
          child: Icon(
            _isComposing ? EvaIcons.paperPlane : EvaIcons.micOutline,
            color: _isComposing ? AppTheme.pureBlack : Colors.grey.shade400,
            size: 20,
          ),
        ),
      ),
    );
  }
}
