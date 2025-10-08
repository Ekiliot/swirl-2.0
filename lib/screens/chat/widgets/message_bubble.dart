import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../../../theme/app_theme.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool showTimestamp;
  final String? timestampText;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;
  final VoidCallback? onDeleteForAll;
  final VoidCallback? onEdit;
  final VoidCallback? onReply;
  final VoidCallback? onForward;
  final VoidCallback? onPin;
  final VoidCallback? onReaction;
  final bool isPinned;

  static const List<String> reactions = [
    '😀', '😂', '😍', '🥰', '😘', '😊', '😉', '😎', '🤔', '😏',
    '👍', '👎', '❤️', '💔', '🔥', '💯', '🎉', '👏', '🙌', '🤝',
    '🤣', '😅', '😋', '🤗', '🤩', '🤨', '😐', '😑', '🙄', '😥',
    '😯', '😴', '🥱', '😫', '😨', '🥳', '😈', '👿', '💀', '💩',
    '🍆', '🍑', '🌚', '🌝', '❤️‍🔥', '🤡',
  ];

  const MessageBubble({
    super.key,
    required this.message,
    this.showTimestamp = false,
    this.timestampText,
    this.onCopy,
    this.onDelete,
    this.onDeleteForAll,
    this.onEdit,
    this.onReply,
    this.onForward,
    this.onPin,
    this.onReaction,
    this.isPinned = false,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late final AnimationController _controller;
  late final Animation<double> _curveAnim;
  // Rect animation can be nullable inside Animation because RectTween.animate may produce Animation<Rect?>
  Animation<Rect?>? _rectAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 320));
    _curveAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _removeOverlay(immediate: true);
    _controller.dispose();
    super.dispose();
  }

  void _removeOverlay({bool immediate = false}) {
    if (_overlayEntry == null) return;
    if (immediate) {
      try {
        _overlayEntry!.remove();
      } catch (_) {}
      _overlayEntry = null;
      return;
    }

    _controller.reverse().then((_) {
      try {
        _overlayEntry?.remove();
      } catch (_) {}
      _overlayEntry = null;
    });
  }

  void _showCupertinoLikeMenu(BuildContext context) async {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset topLeft = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final Rect sourceRect = topLeft & size;

    final Size screenSize = MediaQuery.of(context).size;
    final double horizontalPadding = 36.0;
    final double maxPreviewWidth = 360.0;
    final double previewWidth = (screenSize.width - horizontalPadding * 2).clamp(0.0, maxPreviewWidth);
    final double previewHeight = (size.height * 1.15).clamp(64.0, screenSize.height * 0.45);

    final double targetLeft = (screenSize.width - previewWidth) / 2;
    final double targetTop = screenSize.height * 0.12;
    final Rect targetRect = Rect.fromLTWH(targetLeft, targetTop, previewWidth, previewHeight);

    // Note: RectTween.animate returns Animation<Rect?> so we keep nullable animation type
    _rectAnimation = RectTween(begin: sourceRect, end: targetRect).animate(_curveAnim);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return _CupertinoLikeOverlay(
          controller: _controller,
          rectAnim: _rectAnimation!, // pass Animation<Rect?> (non-null here)
          headerPreviewBuilder: () => _buildPreviewForOverlay(previewWidth, previewHeight),
          actionsBuilder: () => _buildActionsColumn(),
          onDismissRequested: () => _removeOverlay(),
        );
      },
    );

    Overlay.of(context)!.insert(_overlayEntry!);
    HapticFeedback.selectionClick();
    await _controller.forward();
  }

  Widget _buildPreviewForOverlay(double width, double height) {
    final message = widget.message;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        constraints: BoxConstraints(minHeight: 56, maxHeight: height),
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: message.isMine
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.toxicYellow, AppTheme.darkYellow],
                )
              : null,
          color: message.isMine ? null : AppTheme.darkGray,
          border: message.isMine
              ? null
              : Border.all(color: AppTheme.mediumGray.withValues(alpha: 0.5), width: 1),
          boxShadow: message.isMine
              ? [
                  BoxShadow(
                    color: AppTheme.toxicYellow.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                widget.message.text,
                style: GoogleFonts.montserrat(
                  color: message.isMine ? AppTheme.pureBlack : Colors.white,
                  fontSize: 16,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text(
                  _formatTime(widget.message.timestamp),
                  style: GoogleFonts.montserrat(
                    color: message.isMine ? AppTheme.pureBlack.withValues(alpha: 0.7) : Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionsColumn() {
    final List<_ActionItem> actions = [];

    actions.add(_ActionItem(
      icon: EvaIcons.copyOutline,
      label: 'Копировать',
      color: AppTheme.toxicYellow,
      onTap: () {
        Clipboard.setData(ClipboardData(text: widget.message.text));
        widget.onCopy?.call();
        _removeOverlay();
      },
    ));

    if (widget.message.isMine) {
      actions.add(_ActionItem(
        icon: EvaIcons.editOutline,
        label: 'Изменить',
        color: AppTheme.toxicYellow,
        onTap: () {
          widget.onEdit?.call();
          _removeOverlay();
        },
      ));

      actions.add(_ActionItem(
        icon: EvaIcons.trash2Outline,
        label: 'Удалить у себя',
        color: Colors.red,
        onTap: () {
          widget.onDelete?.call();
          _removeOverlay();
        },
      ));

      actions.add(_ActionItem(
        icon: EvaIcons.trash2Outline,
        label: 'Удалить у всех',
        color: Colors.red,
        onTap: () {
          widget.onDeleteForAll?.call();
          _removeOverlay();
        },
      ));
    }

    actions.add(_ActionItem(
      icon: widget.isPinned ? EvaIcons.pin : EvaIcons.pinOutline,
      label: widget.isPinned ? 'Открепить' : 'Закрепить',
      color: AppTheme.toxicYellow,
      onTap: () {
        widget.onPin?.call();
        _removeOverlay();
      },
    ));

    actions.add(_ActionItem(
      icon: EvaIcons.messageCircleOutline,
      label: 'Ответить',
      color: AppTheme.toxicYellow,
      onTap: () {
        widget.onReply?.call();
        _removeOverlay();
      },
    ));

    actions.add(_ActionItem(
      icon: EvaIcons.shareOutline,
      label: 'Переслать',
      color: AppTheme.toxicYellow,
      onTap: () {
        widget.onForward?.call();
        _removeOverlay();
      },
    ));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 62,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: MessageBubble.reactions.length,
            separatorBuilder: (_, __) => SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final emoji = MessageBubble.reactions[idx];
              return GestureDetector(
                onTap: () {
                  widget.onReaction?.call();
                  _removeOverlay();
                },
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: Center(child: Text(emoji, style: TextStyle(fontSize: 24))),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 8),

        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.45,
          ),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: Offset(0, 8))
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: actions.map((a) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActionTile(item: a),
                      if (a != actions.last) Divider(height: 1, color: Colors.grey.shade200),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),

        SizedBox(height: 12),

        Container(
          margin: EdgeInsets.symmetric(horizontal: 18),
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _removeOverlay();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 6,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              shadowColor: Colors.black.withOpacity(0.12),
            ),
            child: Text(
              'Отмена',
              style: GoogleFonts.montserrat(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(height: 18),
      ],
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    final message = widget.message;
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: 300),
              child: _buildBubble(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(BuildContext context) {
    final message = widget.message;
    return GestureDetector(
      onLongPress: () => _showCupertinoLikeMenu(context),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: message.isMine
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.toxicYellow, AppTheme.darkYellow],
                    )
                  : null,
              color: message.isMine ? null : AppTheme.darkGray,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(message.isMine ? 24 : 6),
                bottomRight: Radius.circular(message.isMine ? 6 : 24),
              ),
              border: message.isMine
                  ? null
                  : Border.all(color: AppTheme.mediumGray.withValues(alpha: 0.5), width: 1),
              boxShadow: message.isMine
                  ? [
                      BoxShadow(
                        color: AppTheme.toxicYellow.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      )
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: GoogleFonts.montserrat(
                    color: message.isMine ? AppTheme.pureBlack : Colors.white,
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: GoogleFonts.montserrat(
                        color: message.isMine ? AppTheme.pureBlack.withValues(alpha: 0.7) : Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 8,
            right: message.isMine ? null : 8,
            left: message.isMine ? 8 : null,
            child: _buildReadStatus(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.mediumGray.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.mediumGray.withValues(alpha: 0.5), width: 1),
        ),
        child: Text(
          widget.timestampText ?? '',
          style: GoogleFonts.montserrat(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildReadStatus() {
    final isRead = widget.message.isRead;

    if (widget.message.isMine) {
      if (!isRead) {
        return Icon(Icons.check, size: 18, color: Colors.blue);
      } else {
        return Icon(Icons.done_all, size: 18, color: Colors.blue);
      }
    } else {
      return Icon(Icons.done_all, size: 18, color: Colors.green);
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showTimestamp && widget.timestampText != null) _buildTimestamp(),
        _buildMessageContent(context),
      ],
    );
  }
}

/// Small helper widget that builds the overlay layout and runs the animations.
class _CupertinoLikeOverlay extends StatefulWidget {
  final AnimationController controller;
  // accept Animation<Rect?> because RectTween.animate can produce nullable Rect values
  final Animation<Rect?> rectAnim;
  final Widget Function() headerPreviewBuilder;
  final Widget Function() actionsBuilder;
  final VoidCallback onDismissRequested;

  const _CupertinoLikeOverlay({
    required this.controller,
    required this.rectAnim,
    required this.headerPreviewBuilder,
    required this.actionsBuilder,
    required this.onDismissRequested,
  });

  @override
  State<_CupertinoLikeOverlay> createState() => _CupertinoLikeOverlayState();
}

class _CupertinoLikeOverlayState extends State<_CupertinoLikeOverlay> {
  late final Animation<double> _actionsOpacity;
  late final Animation<Offset> _actionsOffset;

  @override
  void initState() {
    super.initState();
    _actionsOpacity = CurvedAnimation(parent: widget.controller, curve: Interval(0.42, 1.0, curve: Curves.easeOut));
    _actionsOffset = Tween<Offset>(begin: Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: widget.controller, curve: Interval(0.42, 1.0, curve: Curves.easeOut)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onDismissRequested,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(color: Colors.black.withOpacity(0.35)),
              ),
            ),
          ),

          // animated preview (positioned by rectAnim). handle nullable Rect by falling back to Rect.zero
          AnimatedBuilder(
            animation: widget.rectAnim,
            builder: (context, child) {
              final rect = widget.rectAnim.value ?? Rect.fromLTWH(0, 0, 0, 0);
              return Positioned.fromRect(
                rect: rect,
                child: child!,
              );
            },
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.02).animate(
                CurvedAnimation(parent: widget.controller, curve: Interval(0.0, 0.6, curve: Curves.easeOutBack)),
              ),
              child: widget.headerPreviewBuilder(),
            ),
          ),

          Positioned.fill(
            child: AnimatedBuilder(
              animation: widget.rectAnim,
              builder: (context, _) {
                final rect = widget.rectAnim.value ?? Rect.fromLTWH(0, 0, 0, 0);
                final double gap = 12.0;
                final double top = rect.bottom + gap;
                return Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: top,
                      child: SlideTransition(
                        position: _actionsOffset,
                        child: FadeTransition(
                          opacity: _actionsOpacity,
                          child: widget.actionsBuilder(),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _ActionItem({required this.icon, required this.label, required this.color, required this.onTap});
}

class _ActionTile extends StatelessWidget {
  final _ActionItem item;

  const _ActionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isDestructive = item.color == Colors.red;
    final Color iconColor = isDestructive ? Colors.red : AppTheme.toxicYellow;
    return InkWell(
      onTap: item.onTap,
      child: Container(
        height: 56,
        padding: EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, color: iconColor, size: 18),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: GoogleFonts.montserrat(
                  color: isDestructive ? Colors.red : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}