import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_container.dart';
import '../utils/calculator_state.dart';
import '../models/history_item.dart';

class HistoryScreen extends StatelessWidget {
  final CalculatorState state;
  final Function(String)? onTabChangeRequested;

  const HistoryScreen({
    Key? key,
    required this.state,
    this.onTabChangeRequested,
  }) : super(key: key);

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
            _buildHeader(),
            const SizedBox(height: 12),
            // Lista o mensaje vacío
            Expanded(
              child: items.isEmpty
                  ? _buildEmptyState()
                  : _buildHistoryList(items),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Historial de Operaciones',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        if (state.historyList.isNotEmpty)
          InkWell(
            onTap: () => state.clearHistory(),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
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

  Widget _buildEmptyState() {
    return GlassContainer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_toggle_off_outlined,
              size: 44,
              color: Colors.white.withOpacity(0.25),
            ),
            const SizedBox(height: 12),
            Text(
              'No hay operaciones recientes',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white30,
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
                              ? Colors.deepPurple.withOpacity(0.2) 
                              : Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSci 
                                ? Colors.deepPurple.withOpacity(0.3) 
                                : Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          isSci ? 'CIENTÍFICA' : 'MATRICES',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSci ? const Color(0xFFC084FC) : const Color(0xFFFB923C),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      // Time
                      Text(
                        _formatTime(item.timestamp),
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.white24,
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
                      color: Colors.white60,
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
                      color: const Color(0xEEEEEEEE),
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
