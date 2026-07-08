# Sushi Restaurant

Ứng dụng Flutter quản lý nhà hàng sushi theo mô hình MVVM, dùng Firebase cho
đăng nhập/dữ liệu online và SQLite cho dữ liệu local.

## Chạy app trên Chrome bằng Android Studio

File Firebase thật nằm ở máy local và không commit lên git:

```text
firebase_config.local.json
```

Nếu chưa có file này, copy từ:

```text
firebase_config.example.json
```

rồi điền giá trị Firebase thật từ Firebase Console.

Trong Android Studio, chọn run configuration:

```text
main.dart
```

Rồi bấm nút **Run** như bình thường. Configuration này đã truyền sẵn:

```text
--dart-define-from-file=firebase_config.local.json
```

Nếu chạy bằng terminal:

```bash
flutter run -d chrome --dart-define-from-file=firebase_config.layout.json
```

## Lỗi `auth/invalid-api-key`

Lỗi này thường xảy ra khi chạy app bằng lệnh thường:

```bash
flutter run -d chrome
```

Khi đó Firebase nhận API key rỗng vì app không được truyền file config local.
Hãy bấm Run bằng Android Studio với configuration `main.dart`, hoặc chạy terminal
với `--dart-define-from-file=firebase_config.local.json`.
