.PHONY: setup get add test analyze clean run

setup:
	@echo "Initializing project Flutter SDK version..."
	fvm use 3.44.8 --force
	@echo "Fetching packages..."
	fvm flutter pub get

get:
	@echo "Fetching packages..."
	fvm flutter pub get

add:
	@fvm flutter pub add $(pkg)

test:
	@echo "Running unit and widget tests..."
	fvm flutter test

analyze:
	@echo "Running code analysis..."
	fvm flutter analyze

clean:
	@echo "Clearing build artifacts..."
	fvm flutter clean
	fvm flutter pub get

run:
	fvm flutter run