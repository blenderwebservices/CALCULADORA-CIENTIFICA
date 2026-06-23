import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_container.dart';
import '../utils/calculator_state.dart';
import '../models/history_item.dart';

class HistoryScreen extends StatelessWidget {
  final CalculatorState state;
  final Function(String)? onTabChangeRequested;

  const HistoryScreen({
    super.key,
    required this.state,
    this.onTabChangeRequested,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final items = state.historyList;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encabezado
            _buildHeader(context),
            const SizedBox(height: 12),
            // Lista o mensaje vacío
            Expanded(
              child: items.isEmpty
                  ? _buildEmptyState(context)
                  : _buildHistoryList(items),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? Colors.white : const Color(0xFF0F0C1B);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Historial de Operaciones',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        if (state.historyList.isNotEmpty)
          InkWell(
            onTap: () => state.clearHistory(),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                  const SizedBox(width: 4),
                  Text(
                    'Borrar',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiaryText = isDark ? Colors.white38 : Colors.black38;

    return GlassContainer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_toggle_off_outlined,
              size: 44,
              color: tertiaryText,
            ),
            const SizedBox(height: 12),
            Text(
              'No hay operaciones recientes',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: tertiaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(List<HistoryItem> items) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSci = item.type == 'sci';
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryText = isDark ? Colors.white : const Color(0xFF0F0C1B);
        final secondaryText = isDark ? Colors.white60 : Colors.black54;
        final tertiaryText = isDark ? Colors.white24 : Colors.black26;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              // Cargar item en estado
              state.loadHistoryItem(item);

              // Si se solicita, cambiar pestaña
              if (onTabChangeRequested != null) {
                onTabChangeRequested!(isSci ? 'scientific' : 'matrix');
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              borderRadius: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSci 
                              ? Colors.deepPurple.withValues(alpha: isDark ? 0.2 : 0.08) 
                              : Colors.orange.withValues(alpha: isDark ? 0.2 : 0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSci 
                                ? Colors.deepPurple.withValues(alpha: isDark ? 0.3 : 0.15) 
                                : Colors.orange.withValues(alpha: isDark ? 0.3 : 0.15),
                          ),
                        ),
                        child: Text(
                          isSci ? 'CIENTÍFICA' : 'MATRICES',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSci 
                                ? (isDark ? const Color(0xFFC084FC) : Colors.deepPurple) 
                                : (isDark ? const Color(0xFFFB923C) : Colors.orange.shade800),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      // Time
                      Text(
                        _formatTime(item.timestamp),
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: tertiaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Expresión
                  Text(
                    item.expression,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Resultado
                  Text(
                    item.result,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}
