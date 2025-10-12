import 'package:flutter/services.dart';

/// Utility class chứa các InputFormatter thường sử dụng
class InputFormatters {
  InputFormatters._();

  /// Chỉ cho phép nhập số
  static List<TextInputFormatter> get digitsOnly => [
        FilteringTextInputFormatter.digitsOnly,
      ];

  /// Số điện thoại Việt Nam với format (0xxx xxx xxx)
  static List<TextInputFormatter> get phoneNumberFormatted => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
        SimplePhoneFormatter(),
      ];

  /// Họ tên (chỉ chữ cái và khoảng trắng)
  static List<TextInputFormatter> get fullName => [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ỹ\s]')),
        LengthLimitingTextInputFormatter(100),
        NameFormatter(),
      ];

  /// Email (lowercase và loại bỏ khoảng trắng)
  static List<TextInputFormatter> get email => [
        FilteringTextInputFormatter.deny(RegExp(r'\s')), // Không cho phép space
        LowercaseFormatter(),
        LengthLimitingTextInputFormatter(255),
      ];

  /// Số tiền (chỉ số)
  static List<TextInputFormatter> get currency => [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        CurrencyFormatter(),
      ];

  /// Mật khẩu (loại bỏ khoảng trắng)
  static List<TextInputFormatter> get password => [
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
        LengthLimitingTextInputFormatter(50),
      ];
}

class NameFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;

    // Capitalize từng từ
    newText = newText.toLowerCase().split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');

    // Loại bỏ khoảng trắng thừa
    newText = newText.replaceAll(RegExp(r'\s+'), ' ');

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

/// Formatter để chuyển thành lowercase
class LowercaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

/// Formatter cho tiền tệ
class CurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;

    // Chỉ cho phép một dấu chấm
    int dotCount = '.'.allMatches(newText).length;
    if (dotCount > 1) {
      return oldValue;
    }

    // Giới hạn số chữ số sau dấu chấm
    if (newText.contains('.')) {
      List<String> parts = newText.split('.');
      if (parts.length == 2 && parts[1].length > 2) {
        newText = '${parts[0]}.${parts[1].substring(0, 2)}';
      }
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

/// Validator utilities
class Validators {
  Validators._();

  /// Validate số điện thoại Việt Nam
  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) return requiredField(value);

    if (value.length < 10) {
      return 'Số điện thoại phải có ít nhất 10 chữ số';
    }

    if (value.length > 12) {
      return 'Số điện thoại không được quá 12 chữ số';
    }

    // Kiểm tra format số điện thoại Việt Nam
    if (!RegExp(r'^(0[2|3|5|7|8|9])+([0-9]{8,9})$').hasMatch(value)) {
      return 'Số điện thoại không hợp lệ ';
    }

    return null;
  }

  /// Validate email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return requiredField(value);

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email không hợp lệ';
    }

    return null;
  }

  /// Validate required field
  static String? requiredField(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '* Vui lòng nhập $fieldName'
          : '* Vui lòng không bỏ trống';
    }
    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.isEmpty) return null;

    if (value.length < minLength) {
      return fieldName != null
          ? '* $fieldName phải có ít nhất $minLength ký tự'
          : '* Phải có ít nhất $minLength ký tự';
    }
    return null;
  }

  /// Validate password
  static String? password(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) return requiredField(value);
    minLength(value, 6, fieldName);
    return null;
  }

  /// Validate employee ID
  static String? employeeId(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) return requiredField(value);
    minLength(value, 6, fieldName);
    return null;
  }

  /// Validate date range (dd/mm/yyyy đến dd/mm/yyyy)
  static String? dateRange(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    // Check format: dd/mm/yyyy đến dd/mm/yyyy
    RegExp dateRangePattern = RegExp(r'^(\d{2})/(\d{2})/(\d{4}) đến (\d{2})/(\d{2})/(\d{4})$');
    
    if (!dateRangePattern.hasMatch(value)) {
      return 'Định dạng không đúng. Vui lòng nhập theo định dạng: dd/mm/yyyy đến dd/mm/yyyy';
    }
    
    Match match = dateRangePattern.firstMatch(value)!;
    
    try {
      // Parse start date
      int startDay = int.parse(match.group(1)!);
      int startMonth = int.parse(match.group(2)!);
      int startYear = int.parse(match.group(3)!);
      
      // Parse end date
      int endDay = int.parse(match.group(4)!);
      int endMonth = int.parse(match.group(5)!);
      int endYear = int.parse(match.group(6)!);
      
      // Validate date values
      if (startDay < 1 || startDay > 31 || endDay < 1 || endDay > 31) {
        return 'Ngày không hợp lệ (1-31)';
      }
      
      if (startMonth < 1 || startMonth > 12 || endMonth < 1 || endMonth > 12) {
        return 'Tháng không hợp lệ (1-12)';
      }
      
      if (startYear < 1900 || startYear > 2100 || endYear < 1900 || endYear > 2100) {
        return 'Năm không hợp lệ (1900-2100)';
      }
      
      // Create DateTime objects for comparison
      DateTime startDate = DateTime(startYear, startMonth, startDay);
      DateTime endDate = DateTime(endYear, endMonth, endDay);
      
      // Check if start date is after end date
      if (startDate.isAfter(endDate)) {
        return 'Ngày bắt đầu không thể lớn hơn ngày kết thúc';
      }
      
    } catch (e) {
      return 'Ngày tháng không hợp lệ';
    }
    
    return null;
  }
}

/// Formatter đơn giản cho số điện thoại (không bị lỗi khi xóa)
class SimplePhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Chỉ giữ lại số
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Không format nếu đang xóa
    if (digits.length <
        oldValue.text.replaceAll(RegExp(r'[^0-9]'), '').length) {
      return TextEditingValue(
        text: digits,
        selection: TextSelection.collapsed(offset: digits.length),
      );
    }

    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}
