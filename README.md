# ID Wallet App

ID Wallet is a free, native iOS App with a strong focus on data-security that stores credentials like employee-letters or registration-letters (i.e. in a hotel). It furthermore enables the user to share these credentials with third parties as part of i.e. a verification-process.

## Features

The App is still in development and is incomplete in terms of the "full featureset". This means that currently the cannot be used out of the box without first deploying the [Indy Node](https://github.com/My-DIGI-ID/ssi-image-indy-node) and [Mediator](https://github.com/My-DIGI-ID/SSI-Mediator) as well as other required backend components (i.e. agents). In the current implementation, the backend-component are assumed to be hosted in a cloud deployment that may or may not exist right now.

The following features are supported:

- Onboarding the application by entering the personal wallet PIN, which creates a local copy of the indy ledger
- Adding credentials to the `wallet` by scanning a QRCode issued by the aries agent
  - The credential-scanner allows the use of the flashlight to scan QR codes in dark places
- Present information about a credential that is to be added to the wallet
  - If a credential is insecure, a screen explaining the risks of adding the credential to the wallet is displayed (currently this page is displayed when a corresponding setting is enabled, as the credentials are not yet verified)
- After adding credentials, they are displayed in an iOS wallet like list of cards that show general information about the credential (like the issuer, a name, expiration date etc.).

## Development Requirements

The App uses the Swift Package Manager to manage its dependencies. All dependencies are hosted on GitHub (private) and require the following setup:

- Valid SSH key configured for Access to GitHub
- Personal Access Token configured to allow access to the My-DIGI-ID repositories
- The user must be a member of the My-DIGI-ID group
- The GitHub Account (Access Token) must be added to Xcode
