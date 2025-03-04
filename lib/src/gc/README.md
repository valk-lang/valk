
# Strategy

```
data.state = (disconnected, connected, shared-disconnected, shared)
data.shared_age = u8
data.in_list = (recon/discs)
data.on_stack = bool
data.u2 = u8
data.prop_count = u8
data.offset = u16

- set .on_stack = true for current stack items
- loop previous stack items, disconnect where .on_stack == false
//- set from_stack = true
- mark stack items recursive
-- if .state != 0 : return false
-- otherwise: set .state = 1, loop properties, call hook
//- set from_stack = false
- loop disconnects
-- disconnect recursive
- loop reconnects
-- reconnect recursive
- loop disconnects
-- free disconnected items recursive
```
