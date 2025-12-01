import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:quan_ly_tai_san_app/screen/tool_and_material_transfer/model/tool_and_material_transfer_dto.dart';
// import 'package:quan_ly_tai_san_app/screen/tool_and_material_transfer/repository/tool_and_material_transfer_reponsitory.dart';
import 'package:table_base/widgets/table/providers/table_notifier.dart';
import 'package:table_base/widgets/table/providers/table_state.dart';

// Giả sử model và repository của bạn
class ToolAndMaterialTransferDto {
  final String id;
  final String name;
  ToolAndMaterialTransferDto({required this.id, required this.name});
}

class ToolAndMaterialTransferRepository {
  Future<List<ToolAndMaterialTransferDto>> getData({
    required int page,
    required int limit,
    String? searchTerm,
  }) async {
    // Implement API call
    return [];
  }
  
  Future<ApiPaginationResponse> getDataWithPagination({
    required int page,
    required int limit,
    String? searchTerm,
  }) async {
    // Implement API call with pagination info
    return ApiPaginationResponse(
      data: [],
      totalPages: 0,
      currentPage: page,
      totalItems: 0,
    );
  }
}

class ApiPaginationResponse {
  final List<ToolAndMaterialTransferDto> data;
  final int totalPages;
  final int currentPage;
  final int totalItems;
  
  ApiPaginationResponse({
    required this.data,
    required this.totalPages,
    required this.currentPage,
    required this.totalItems,
  });
}

// Provider cho repository
final toolAndMaterialTransferRepositoryProvider = Provider<ToolAndMaterialTransferRepository>((ref) {
  return ToolAndMaterialTransferRepository();
});

// Provider cho table - FIXED VERSION
final tableToolAndMaterialTransferProvider = StateNotifierProvider.autoDispose<
  TableToolAndMaterialTransferProvider,
  GenericTableState<ToolAndMaterialTransferDto>
>((ref) {
  final repository = ref.read(toolAndMaterialTransferRepositoryProvider);
  return TableToolAndMaterialTransferProvider(repository);
});

class TableToolAndMaterialTransferProvider
    extends TableNotifier<ToolAndMaterialTransferDto> {
  
  final ToolAndMaterialTransferRepository repository;
  String _currentSearchTerm = '';
  
  TableToolAndMaterialTransferProvider(this.repository);

  // FIXED: Đúng signature với named parameters
  @override
  void initialize({
    required Map<String, double> columnWidths,
    required dynamic Function(ToolAndMaterialTransferDto item, int columnIndex) valueGetter,
    int itemsPerPage = 20,
  }) {
    super.initialize(
      columnWidths: columnWidths,
      valueGetter: valueGetter,
      itemsPerPage: itemsPerPage,
    );
    
    // Bật API pagination và load dữ liệu đầu tiên
    enableApiPagination(true);
    loadDataFromApi(0);
  }

  // Tìm kiếm
  set searchTerm(String value) {
    _currentSearchTerm = value;
    
    if (state.paginationState.useApiPagination) {
      // API pagination: reset về trang đầu và gọi API
      loadDataFromApi(0);
    } else {
      // Local pagination: tìm kiếm trong data có sẵn
      search(value);
    }
  }

  // Load dữ liệu từ API với pagination
  Future<void> loadDataFromApi(int page) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final response = await repository.getDataWithPagination(
        page: page,
        limit: state.paginationState.itemsPerPage,
        searchTerm: _currentSearchTerm.isEmpty ? null : _currentSearchTerm,
      );
      
      // Cập nhật data và pagination info từ API
      setApiData(
        response.data,
        totalPages: response.totalPages,
        currentPage: response.currentPage,
        totalItems: response.totalItems,
      );
    } catch (error) {
      log('Error loading data from API: $error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi tải dữ liệu: $error',
      );
    }
  }

  // Override goToPage để tự động gọi API khi chuyển trang
  @override
  void goToPage(int page) {
    super.goToPage(page);
    
    if (state.paginationState.useApiPagination) {
      loadDataFromApi(page);
    }
  }

  // Refresh dữ liệu hiện tại
  Future<void> refreshData() async {
    if (state.paginationState.useApiPagination) {
      await loadDataFromApi(state.paginationState.currentDisplayPage);
    } else {
      await loadData();
    }
  }

  // Chuyển về local pagination mode (nếu cần)
  void setLocalData(List<ToolAndMaterialTransferDto> data) {
    enableApiPagination(false);
    loadData(data);
  }

  @override
  Future<List<ToolAndMaterialTransferDto>> generateData() async {
    // Method này chỉ được gọi trong local pagination mode
    // Trong API pagination mode, dữ liệu được set qua setApiData()
    return [];
  }
}