# ``IDWallet``

## About this Documentation

This documentation has been created using DocC, its sources are part of the ID Wallet App.

The purpose of this document is to explain the architecture of the application, how elements
of the App play together and other odds and ends.

The documentation generated from source code is assumed to be up to date and accurate.
Auxilliary documentation such as this text might fall behind and be more or less outdated
but should still be valuable in explaining the concepts as intended at the time of writing.

The audience for this documentation are development team members, it's not intended to
be published beyond this scope. That also means that if you are part of the team your are
welcome to contribute to this effort for the sake of your fellow coders.

Well that was the intention. [As others also pointed out](https://www.hackingwithswift.com/articles/238/how-to-document-your-project-with-docc),
DocC actually does not support generating documentation for Apps.

> Except it isn’t, at least not in the way I had hoped. You see, at this time DocC supports only frameworks and packages, which means it picked out only the external packages used by my app as opposed to all the app code itself. This is a bit of a shame, to be honest, because the overwhelming majority of us work on actual app projects, and when someone new joins a team it would be great to give them some clear, readable documentation to help on-ramp them.

So for the time beeing, this enterprise is beeing abandoned in favour to README.md files
which you might find along sources.

I will leave this file here in case a recent version of Xcode might actually support this
so that we can pick up where I left.

## Overview

This module covers the user interface of the App exclusively. All backend functionality is
provided by separate packages as is their documentation.

## Topics

### Note worthy classes

- ``BaseViewController``
