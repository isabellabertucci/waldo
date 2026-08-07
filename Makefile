.PHONY: setup run analyze format test gen

setup:
	@echo "Initializing project Flutter SDK version..."
	fvm use 3.44.8 --force
	@echo "Fetching packages..."
	fvm flutter pub get

run:
	fvm flutter run

analyze:
	@echo "Running code analysis..."
	fvm flutter analyze

format:
	@echo "Checking code formatting..."
	fvm dart format --output=none --set-exit-if-changed .

test:
	@echo "Running unit and widget tests..."
	fvm flutter test

add:
	fvm flutter pub add $(pkg)

add-dev:
	fvm flutter pub add dev:$(pkg)

gen: 
	fvm dart run build_runner build --delete-conflicting-outputs