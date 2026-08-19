# Food Delivery Flutter

This folder is a clean Flutter base for migrating the existing food delivery application.

## Current status

The original repo is not a Flutter project. It is a React Native + Expo monorepo with a React admin dashboard. This folder creates the base Flutter structure needed to start the migration.

## Project structure

- `lib/app` : app root and routing
- `lib/core` : theme, services, storage, constants
- `lib/features` : domain modules (auth, home, orders, rider, profile)
- `lib/models` : DTOs and API models

## Next migration steps

1. Review the GraphQL/REST API contract used by the existing apps.
2. Port the login flow and session token storage.
3. Rebuild the menu, cart, and order screens.
4. Port rider flows and live order tracking.
5. Add Firebase push notifications and location permissions.

## Important note

Flutter SDK is not installed in this environment, so this scaffold is created as a source-structure starting point rather than a built app.
