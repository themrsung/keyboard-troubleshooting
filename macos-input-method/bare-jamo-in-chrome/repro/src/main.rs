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
