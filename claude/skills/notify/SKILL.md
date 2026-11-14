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

## When you need a decision

If the notification is a question, put the answer options in it, so he can
decide from the lock screen and reply with a single character when he is
back:

```sh
ntfy-cmd claude "loq: the migration needs a schema change that drops the old sessions table. How do I proceed?
1) drop it, the data is stale (my pick)
2) rename it to sessions_old and keep it
3) stop here, you will look yourself"
```

- The question first, in one sentence, with what is at stake.
- Then two to four numbered options, one per line, each a complete action
  he can pick without reading anything else. Say what each one costs if it
  is not obvious.
- Mark the one you recommend with "(my pick)".
- Ask the same question with the same numbering in your reply in the
  terminal, so "2" there means what it meant on the phone. He cannot answer
  through ntfy; you wait for him in the session.

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
