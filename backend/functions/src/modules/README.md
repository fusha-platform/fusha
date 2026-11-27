# Backend modules

Create a module here only when its domain contract and implementation gates are approved.

Each module owns its internals and follows this dependency direction:

- `presentation` adapts an approved external entry point to an application use case.
- `application` coordinates a use case and declares the ports it needs.
- `domain` contains business rules and has no framework, Firebase, or infrastructure imports.
- `infrastructure` implements ports and owns persistence/provider-specific adapters.

Modules collaborate only through explicitly exposed application interfaces, domain events, or approved read models. A module must not import another module's private repository or infrastructure implementation.
