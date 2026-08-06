# Testing Notes

A practical guide for how we write tests in this project.

## setUp and tearDown

Every test file can have a `setUp` and a `tearDown`.

- `setUp` runs **before each test** in the file. Use it to create fresh things a test needs, like a new in-memory database or a new repository.
- `tearDown` runs **after each test** in the file, even if the test failed. Use it to clean up, like closing a database connection.

```dart
void main() {
  late Database db;
  late WalletRepositoryImpl repo;

  setUp(() async {
    db = await createTestDatabase();
    repo = WalletRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('...', () async { ... });
}
```

Why this matters: without `tearDown`, connections pile up between tests and can cause the whole test run to hang. We hit this bug for real in this project.

## Real database vs. Mock

There are two ways to test code that talks to a repository.

**1. Real database (in-memory)**

Use `sqflite_common_ffi` to spin up a real SQLite database that only lives in memory during the test, then throw it away.

Use this for: **repository tests**. The repository's whole job is to talk to the database correctly, so it needs to talk to a real one.

**2. Mock**

Use a package like `mocktail` to create a fake version of the repository that never touches a database. You tell it what to return.

```dart
class MockWalletRepository extends Mock implements IWalletRepository {}
```

Use this for: **view model tests**. The view model's job is to coordinate, not to run SQL. A mock lets you test "does the view model call `insert` with the right data?" without needing a database at all.

Rule of thumb: test the repository against a real database. Test the view model against a mock repository.

## Thinking through test cases for a repository method

For every method, ask: what are all the realistic outcomes, not just the happy path?

Example, for `getById(id)`:
- The id exists → returns the wallet
- The id does not exist → returns `null`, does not throw

Example, for `delete(id)`:
- The wallet has no related rows → deletes successfully
- The wallet has related rows (a transaction pointing to it) → the foreign key constraint blocks it, and we turn that into a friendly error instead of crashing

A quick way to find these cases: for each method, list what could be true about the input and the state of the database before calling it. Empty database, matching row, no matching row, row with dependents, invalid input.

## Widget tests: keep them deterministic

A "flaky" test is one that sometimes passes and sometimes fails without any code change. Common causes we've run into:

- Relying on the device or CI machine's language setting. Fix: always pin `locale` to a fixed value (e.g. English) in test widgets.
- Tapping something before its entrance animation has finished (like a snackbar). Fix: `pump()` a small extra duration after the action that triggers the animation.
- Reusing state (like a database) between tests without resetting it. Fix: create fresh state in `setUp`, dispose it in `tearDown`.

## A test that "passes for the wrong reason"

A test can pass without actually proving anything. Example: a widget test that navigates to a screen needing a database, but the test never provides one. In our test environment, that throws a plugin error, the screen shows an error state, and a `find.byType(SomeScreen)` check still finds the widget, since the widget itself still exists on screen. The test goes green, but it never confirmed the screen actually works with real data.

Fix: always override the dependencies a screen needs (database, repositories) with test versions, even if the test doesn't look like it's testing that dependency directly.

## Mocktail cheat sheet

```dart
// Define the mock
class MockWalletRepository extends Mock implements IWalletRepository {}

// Register a fallback for custom types used with any()/captureAny()
setUpAll(() {
  registerFallbackValue(const Wallet(name: '', createdAt: '...'));
});

// Tell the mock what to return
when(() => mockRepo.insert(any())).thenAnswer((_) async => 1);

// Confirm a method was called, and capture what it was called with
final captured = verify(() => mockRepo.insert(captureAny())).captured.single;

// Confirm a method was never called
verifyNever(() => mockRepo.insert(any()));
```