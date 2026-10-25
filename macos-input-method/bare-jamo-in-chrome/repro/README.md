# Reproduction: the implied-ㅇ diagnostic, checked against the engine

What this checks: the premise of the diagnostic above, that JIS Korean's engine never commits a
bare `ㅏ` for ordinary typing, even when forced to commit after every key, so bare jamo on screen
mean the engine didn't see the keys. It doesn't reproduce the Chrome bug itself, which needs a
Mac and a foreground app.

Tested 2026-10-23 on Linux (x86-64), Rust stable, against JIS Korean at
[`72dcc4b`](https://github.com/team-mirae/jis-korean/commit/72dcc4b), lite engine
(`default-features = false`), Mode A.

## Steps

1. Clone JIS Korean next to this repository (or change the `path` in `Cargo.toml`):
   `git clone https://github.com/team-mirae/jis-korean`.
2. `cargo run` in this folder. The two files below are also in it.

`Cargo.toml`:

```toml
[package]
name = "implied-ieung"
version = "0.0.0"
edition = "2024"
publish = false

[dependencies]
jis-korean-engine = { path = "../../../../jis-korean/engine", default-features = false }
```

`src/main.rs` (the key names it passes are browser `KeyboardEvent.code` strings, the engine's
input: `KeyQ`, `KeyK`, … are the canonical names too, and `F6` is `KeyFunctionSix`):

```rust
use jis_korean::{Engine, Key, Mods};

// Types the keys, then flushes once.
fn run(keys: &str) {
    let mut e = Engine::new();
    let (mut doc, mut pre) = (String::new(), String::new());
    for code in keys.split_whitespace() {
        let out = e.key(Key::from_code(code), Mods::NONE);
        doc.push_str(&out.commit);
        pre = out.preedit;
    }
    doc.push_str(&e.flush().commit);
    println!("{keys:40} -> preedit before flush {pre:?}, text after flush {doc:?}");
}

// Forces a commit after every key.
fn run_flush_each(keys: &str) {
    let mut e = Engine::new();
    let mut doc = String::new();
    for code in keys.split_whitespace() {
        doc.push_str(&e.key(Key::from_code(code), Mods::NONE).commit);
        doc.push_str(&e.flush().commit);
    }
    println!("{keys:40} -> flushed after every key {doc:?}");
}

fn main() {
    run_flush_each("KeyQ KeyK KeyE KeyK KeyT KeyK KeyW KeyK");
    run("KeyK");
    run("KeyQ KeyK KeyE KeyK");
    run("KeyQ KeyK KeyE KeyK KeyT KeyK KeyW KeyK");
    run("KeyK F6");
}
```

## Result

```
KeyQ KeyK KeyE KeyK KeyT KeyK KeyW KeyK  -> flushed after every key "ㅂ아ㄷ아ㅅ아ㅈ아"
KeyK                                     -> preedit before flush "아", text after flush "아"
KeyQ KeyK KeyE KeyK                      -> preedit before flush "바다", text after flush "바다"
KeyQ KeyK KeyE KeyK KeyT KeyK KeyW KeyK  -> preedit before flush "바다사자", text after flush "바다사자"
KeyK F6                                  -> preedit before flush "", text after flush "ㅏ"
```

Committing after every key gives `ㅂ아ㄷ아ㅅ아ㅈ아`, not `ㅂㅏㄷㅏㅅㅏㅈㅏ`. The one sequence here
that gives a bare `ㅏ` is `ㅏ F6`, F6 (`KeyFunctionSix`) being the key that drops the implied ㅇ on
purpose (also in JIS Korean's golden test `f6_drops_implied_ieung_and_commits`).
