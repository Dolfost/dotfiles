---
name: notify
description: Send Vladyslav a push notification on his phone through his ntfy server (topic `claude`). Use when he asks to be notified, pinged or messaged ("tell me when it's done", "ping me"), and on your own when he is likely away from the terminal and a long-running task has finished, failed, or is blocked on a decision only he can make.
---

# Notifying Vladyslav

He runs his own ntfy server and reads the topic `claude` on his phone. To
reach him:

```sh
ntfy-cmd claude "aorus: nixos-rebuild finished, 2 warnings, waiting for you to review"
```

`ntfy-cmd TOPIC MESSAGE...` is on the PATH of his NixOS machines (aorus, loq,
tissot). It publishes with a token it reads from sops; you never need the
token and should not go looking for it.

## The message

It arrives on a phone lock screen with no other context, so make it stand on
its own:

- Start with the machine's hostname and what the task was.
- Then the outcome, and what he has to do, if anything.
- One or two sentences, plain text. No markdown, no secrets, no long output.

## When

- He asked for it: always, once, at the point he named.
- He did not ask: only for something worth interrupting him. A task that ran
  for many minutes and is finished or has failed, or a blocker that needs his
  decision. Not for progress updates, and not while he is plainly at the
  keyboard answering you.
- One notification per event. Do not repeat it if he does not react.

## Limits

- Publish to `claude` only. The other topics on that server drive machines
  (`aorus-cmd` wakes and hibernates one); never post to them unless he asks
  for exactly that.
- If `ntfy-cmd` is missing (the Mac, or a machine outside the fleet) or it
  fails, say so in your reply and carry on. Do not work around it with curl
  or search for a token.
- A notification is in addition to your normal reply, not instead of it.
