# Cardmarket wizard 🧙‍♂️

Improved cardmarket shopping wizard.
Finds the best combination of sellers for cards on your wants lists. 🪄

Currently only supports Yu-Gi-Oh!.

## How does it work?

This application guides you through the process step-by-step, but here is the general idea:

- The application will start a controlled Chromium browser.
- Use the browser to login and navigate to your wants list.  
  I assure you that your credentials are not read, but feel free to check the code.
- Now leave the browser alone and confirm your wants list in the application.
- The browser will automatically visit each article on your wants list to find the best offers for each.
- The browser will then visit some promising sellers to optimize shipping costs.
- You will then be shown the best combination of sellers to purchase your wants from.

## Requirements

- Windows (other platforms might work, but have not been tested)
- [Flutter](https://docs.flutter.dev/get-started/install)

## Installation

```bash
flutter pub get
```

## Running

```bash
flutter run
```

## Testing

```bash
flutter test
```

## Authors

Micha Sengotta ([michasng](https://github.com/michasng))

## License

The code present in this repository is under [MIT license](https://github.com/michasng/cm-wizard/blob/main/LICENSE).

## Acknowledgments

Thank You to [BenSouchet](https://github.com/BenSouchet), author of the original [cw-wizard](https://github.com/BenSouchet/cw-wizard), which inspired this project.
