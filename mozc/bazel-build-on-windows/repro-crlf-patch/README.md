# Reproduction: `git apply` rejects a patch with CRLF line endings

What this checks: a patch whose lines end in CRLF doesn't apply to an LF file, and a `*.patch text
eol=lf` attribute gives back an LF patch on checkout that applies. It doesn't involve PowerShell;
CRLF is added with `sed` to stand in for what PowerShell wrote.

Tested 2026-10-23 on Linux, git 2.43.0.

```sh
git init -q r && cd r
printf 'line one\nline two\n' > f.txt
git add f.txt && git -c user.email=x@x -c user.name=x commit -qm init
sed -i 's/two/2/' f.txt && git diff > ../lf.patch && git checkout -q f.txt
sed 's/$/\r/' ../lf.patch > ../crlf.patch

git apply --check ../lf.patch && echo ok
git apply --check ../crlf.patch; echo "exit $?"

echo '*.patch text eol=lf' > .gitattributes
cp ../crlf.patch p.patch
git add .gitattributes p.patch && git -c user.email=x@x -c user.name=x commit -qm patch
rm p.patch && git checkout -q p.patch
git apply --check p.patch && echo "applies after checkout"
```

Result:

```
ok
error: patch failed: f.txt:1
error: f.txt: patch does not apply
exit 1
warning: in the working copy of 'p.patch', CRLF will be replaced by LF the next time Git touches it
applies after checkout
```

As the warning shows, the copy on disk stayed CRLF after `git add`; the LF version appeared when
Git wrote the file again on checkout.
