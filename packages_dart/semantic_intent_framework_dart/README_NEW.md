[TASK]
Suggest 30 ideas how to name package.

[DESCRIPTION]
I want to build system for dart, that can be separated to three levels of complexity:

1. zero latency systems (reusable systems based on ECS). Uses mutable data, knows about E and C. May use Object pooling and advanced method of memory optimization. Utilizes game loop.
2. Data heavy | command -> stream -> handler - state accessor: for background tasks. Compltely logically isolated, uses immutable data. Useful for serialization, save/export operations. Utilizes observable.
3. UI builder | command - state
