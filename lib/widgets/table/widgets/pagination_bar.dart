import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/core/themes/app_color.dart';
import '../providers/table_state.dart';
import '../providers/table_notifier_interface.dart';
import 'page_button.dart';

/// Thanh phân trang (UI) tách riêng khỏi bảng (logic nằm ở Notifier)
/// - Nhận [tableProvider] để đọc `state` và gọi các hàm điều hướng trang
/// - Tự ẩn khi `totalPages <= 1`
class PaginationBar<T> extends ConsumerWidget {
  final AutoDisposeStateNotifierProvider<
    TableNotifierInterface<T>,
    GenericTableState<T>
  >
  tableProvider;

  const PaginationBar({super.key, required this.tableProvider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableState = ref.watch(tableProvider);
    final notifier = ref.read(tableProvider.notifier);
    final pagination = tableState.paginationState;

    if (pagination.totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: .2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: 'Trang đầu',
            icon: const Icon(Icons.first_page),
            onPressed:
                pagination.canGoPrevious ? () => notifier.firstPage() : null,
          ),
          IconButton(
            tooltip: 'Trang trước',
            icon: const Icon(Icons.chevron_left),
            onPressed:
                pagination.canGoPrevious ? () => notifier.previousPage() : null,
          ),
          Row(children: _buildPaginationButtons(pagination, notifier)),
          IconButton(
            tooltip: 'Trang sau',
            icon: const Icon(Icons.chevron_right),
            onPressed: pagination.canGoNext ? () => notifier.nextPage() : null,
          ),
          IconButton(
            tooltip: 'Trang cuối',
            icon: const Icon(Icons.last_page),
            onPressed: pagination.canGoNext ? () => notifier.lastPage() : null,
          ),
        ],
      ),
    );
  }

  /// Sinh danh sách nút trang với dấu `...` thông minh
  List<Widget> _buildPaginationButtons(dynamic pagination, dynamic notifier) {
    const int maxVisiblePages = 7; // Số trang tối đa hiển thị
    const int sidePages = 2; // Số trang hiển thị ở mỗi bên

    final List<Widget> buttons = [];
    final int totalPages = pagination.totalPages;
    final int currentPage = pagination.currentPage;

    if (totalPages <= maxVisiblePages) {
      for (int i = 0; i < totalPages; i++) {
        buttons.add(
          PageButton(
            pageIndex: i,
            currentPage: currentPage,
            notifier: notifier,
          ),
        );
      }
    } else {
      final Set<int> pagesToShow = {};
      pagesToShow.add(0); // trang đầu
      pagesToShow.add(totalPages - 1); // trang cuối

      for (
        int i = (currentPage - sidePages);
        i <= (currentPage + sidePages);
        i++
      ) {
        if (i >= 0 && i < totalPages) {
          pagesToShow.add(i);
        }
      }

      final List<int> sortedPages = pagesToShow.toList()..sort();
      for (int i = 0; i < sortedPages.length; i++) {
        final int pageIndex = sortedPages[i];
        if (i > 0 && sortedPages[i] - sortedPages[i - 1] > 1) {
          buttons.add(_buildEllipsis());
        }
        buttons.add(
          PageButton(
            pageIndex: pageIndex,
            currentPage: currentPage,
            notifier: notifier,
          ),
        );
      }
    }

    return buttons;
  }

  Widget _buildEllipsis() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: Text(
            '...',
            style: TextStyle(
              color: AppColor.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
