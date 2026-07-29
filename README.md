# waldo

## Flutter version

This project uses [FVM](https://fvm.app/) to pin the Flutter SDK version.

1. Install FVM: `brew install fvm` (macOS) or `curl -fsSL https://fvm.app/install.sh | bash` (Linux)
2. Run `make setup` to install the pinned version and fetch dependencies
3. Use `make run` to run the app

## Development

Adding a migration
Create lib/core/database/migrations/vXX_name.dart (use zero-padded numbers):

````dart
import 'package:sqflite/sqflite.dart';
import '../../constants/db_constants.dart';

Future<void> up(Database db) async {
  await db.execute('ALTER TABLE ... ADD COLUMN ...');
}
````

Register it in lib/core/database/migrations.dart:

```dart
import 'migrations/vXX_name.dart' as m000XX;

final migrations = <Future<void> Function(Database db)>[
  m00001.up,
  m00002.up,
  m000XX.up, // <-- add here
];
```

The database version auto-derives from migrations.length, so no other changes are needed.
