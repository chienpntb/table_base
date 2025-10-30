## API Pagination cho Table

### Tổng quan
Table component hiện tại đã được cập nhật để hỗ trợ phân trang từ API. Có hai chế độ phân trang:

1. **Local Pagination**: Phân trang dữ liệu đã có trong bộ nhớ (chế độ mặc định)
2. **API Pagination**: Phân trang dựa trên thông tin từ API response

### Cách sử dụng API Pagination

#### 1. Kích hoạt chế độ API Pagination

```dart
// Trong notifier của bạn
tableNotifier.enableApiPagination(true);
```

#### 2. Thiết lập thông tin phân trang từ API

```dart
// Khi nhận response từ API
tableNotifier.setApiPaginationInfo(
  totalPages: apiResponse.totalPages,
  currentPage: apiResponse.currentPage,
  totalItems: apiResponse.totalItems, // optional
);
```

#### 3. Cập nhật dữ liệu từ API

```dart
// Cập nhật dữ liệu cho trang hiện tại
tableNotifier.setApiData(
  apiResponse.data,
  totalPages: apiResponse.totalPages,
  currentPage: apiResponse.currentPage,
  totalItems: apiResponse.totalItems,
);
```

### Ví dụ hoàn chỉnh

#### Cách 1: Thiết lập TRONG Provider (Khuyến nghị)
```dart
class MyTableNotifier extends TableNotifier<MyModel> {
  final ApiService _apiService;
  
  MyTableNotifier(this._apiService);

  @override
  void initialize({
    required Map<String, double> columnWidths,
    required dynamic Function(MyModel item, int columnIndex) valueGetter,
    int itemsPerPage = 20,
  }) {
    super.initialize(
      columnWidths: columnWidths,
      valueGetter: valueGetter,
      itemsPerPage: itemsPerPage,
    );
    
    // Kích hoạt API pagination
    enableApiPagination(true);
    
    // Load dữ liệu trang đầu
    loadDataFromApi(0);
  }

  Future<void> loadDataFromApi(int page) async {
    // Bước 1: Set loading state và clear data cũ
    notifier.setApiLoading();
    
    try {
      final response = await _apiService.getData(
        page: page,
        limit: state.paginationState.itemsPerPage,
      );
      
      // Bước 2: Cập nhật dữ liệu thành công
      notifier.setApiData(
        response.data,
        totalPages: response.totalPages,
        currentPage: response.currentPage,
        totalItems: response.totalItems,
      );
    } catch (error) {
      // Bước 3: Set error state
      notifier.setApiError('Lỗi tải dữ liệu: $error');
    }
  }

  @override
  void goToPage(int page) {
    super.goToPage(page); // Cập nhật state pagination
    loadDataFromApi(page); // Load dữ liệu từ API cho trang mới
  }
}
```

#### Cách 2: Thiết lập NGOÀI Provider (Linh hoạt)
```dart
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Thiết lập API pagination khi build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setupApiPagination(ref);
    });

    return Scaffold(
      body: RiverpodTable<MyModel>(
        tableProvider: myTableProvider,
        columns: columns,
        valueGetter: valueGetter,
      ),
    );
  }
  
  void setupApiPagination(WidgetRef ref) {
    final notifier = ref.read(myTableProvider.notifier);
    
    // Sử dụng setupApiPagination với callback
    notifier.setupApiPagination(
      onPageChanged: (page) => loadDataFromApi(ref, page),
      initialTotalPages: 10,
      initialCurrentPage: 0,
    );
    
    // Load dữ liệu ban đầu
    loadDataFromApi(ref, 0);
  }
  
  Future<void> loadDataFromApi(WidgetRef ref, int page) async {
    final notifier = ref.read(myTableProvider.notifier);
    
    try {
      final response = await apiService.getData(page: page);
      
      notifier.setApiData(
        response.data,
        totalPages: response.totalPages,
        currentPage: response.currentPage,
      );
    } catch (error) {
      // Handle error
    }
  }
}
```

### Lưu ý quan trọng

1. **Khi sử dụng API pagination**:
   - Method `goToPage()` chỉ cập nhật trạng thái trang, không cập nhật dữ liệu
   - Bạn cần tự implement logic gọi API để load dữ liệu mới
   - Sử dụng `setApiData()` để cập nhật dữ liệu sau khi nhận từ API

2. **Khi chuyển về Local pagination**:
   ```dart
   tableNotifier.enableApiPagination(false);
   tableNotifier.loadData(allData); // Load toàn bộ dữ liệu
   ```

3. **Pagination Bar sẽ tự động**:
   - Hiển thị số trang dựa trên `totalPagesFromApi` (khi sử dụng API pagination)
   - Hiển thị trang hiện tại dựa trên `currentPageFromApi`
   - Sử dụng `currentDisplayPage` để hiển thị trang hiện tại chính xác

### API Response Format Khuyến nghị

```json
{
  "data": [...],
  "pagination": {
    "currentPage": 0,
    "totalPages": 10,
    "totalItems": 200,
    "itemsPerPage": 20
  }
}
```