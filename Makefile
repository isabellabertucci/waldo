.PHONY: setup run analyze format test

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